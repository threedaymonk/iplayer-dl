require 'tempfile'

module IPlayer
class Downloader

  PROGRAMME_URL  = 'http://www.bbc.co.uk/iplayer/page/item/%s.shtml'
  SELECTOR_URL   = 'http://www.bbc.co.uk/mediaselector/3/auth/iplayer_streaming_http_mp4/%s?%s'
  BUG_URL        = 'http://www.bbc.co.uk/iplayer/framework/img/o.gif?%d'
  MAX_SEGMENT    = 4 * 1024 * 1024
  COPY_BUFFER    = 4 * 1024 * 1024

  include IPlayer::Errors

  class Segment
    attr_reader :start, :end
    attr_accessor :tag

    def initialize(start_at, end_at, tag=nil)
      @start = start_at
      @end   = end_at
      @tag   = tag
    end

    def finished?
      @finished
    end

    def finish!
      @finished = true
    end
  end

  Version = Struct.new(:name, :pid)

  attr_reader   :browser, :pid
  attr_accessor :cookies

  def initialize(browser, pid)
    @browser = browser
    @pid = pid
  end

  def get(url, user_agent, options={}, &blk)
    options['User-Agent'] = user_agent
    options['Cookie'] = cookies if cookies
    browser.get(url, options, &blk)
  end
  
  def versions
    begin
      JavaScript.parse(programme_page_html[/ iplayer\.versions \s* = \s* ( \[ .*? \] ); /mx, 1])
    rescue 
      raise ParsingError
    end
  end

  def available_versions
    versions.inject([]){ |av, version|
      if (version[:iplayer_streaming_http_mp4].any?{ |stream|
        stream[:start] < DateTime.now && stream[:end] > DateTime.now })
        av << Version.new(version[:type], version[:pid])
      end
      av
    }
  end

  def download(version_pid, io, offset=0, &blk)
    # Request the image bugs
    bugs.each do |url|
      get(url, Browser::IPHONE_UA)
    end

    # Get the auth URL
    r = (rand * 10000000).floor
    selector = SELECTOR_URL % [version_pid, r]
    response = get(selector, Browser::QT_UA, 'Range'=>'bytes=0-1')
    
    # It redirects us to the real stream location
    location = response.to_hash['location']
    if location =~ /error\.shtml/
      raise FileUnavailable
    end

    # The first request of CoreMedia is always for the first byte
    response = get(location, Browser::QT_UA, 'Range'=>'bytes=0-1')

    # We now know the full length of the content
    content_range = response.to_hash['content-range']
    unless content_range
      raise FileUnavailable
    end
    content_length = content_range[/\d+$/].to_i
    bytes_got = 0
    io.seek(bytes_got)
    yield(bytes_got, content_length) if block_given?
    tail_io = Tempfile.new('iplayer-dl')
    tail_io.binmode # for windows

    segments = [Segment.new(0, 511, :first)]
    segment_data = nil
    while segment = segments.find{ |s| !s.finished? }
      segment_data = ''
      get(location, Browser::QT_UA, 'Range'=>"bytes=#{segment.start}-#{segment.end}") do |response|
        response.read_body do |data|
          bytes_got += data.length
          segment_data << data
          yield(bytes_got, content_length) if block_given?
        end
      end
      segment.finish!
      case segment.tag
      when :first # Parse and skip ahead
        atom_name = nil
        offset = 0
        until atom_name == 'mdat'
          atom_name = segment_data[offset+4,4]
          offset += segment_data[offset,4].unpack('N')[0]
        end
        moov_start = offset
        moov_start.step(content_length - 1, MAX_SEGMENT) do |a|
          b = [a + MAX_SEGMENT - 1, content_length - 1].min
          segments << Segment.new(a, b, :tail)
        end
        512.step(moov_start - 1, MAX_SEGMENT) do |a|
          b = [a + MAX_SEGMENT - 1, moov_start - 1].min
          segments << Segment.new(a, b)
        end
        io << segment_data
      when :tail # Cache in temporary file for later
        tail_io << segment_data
      else # Just write it out
        io << segment_data
      end
    end
    # Write out the cached segments at the end
    tail_io.open
    tail_io.binmode # again, for windows
    until tail_io.eof?
      io << tail_io.read(COPY_BUFFER)
    end
    tail_io.close
  end

private

  def programme_page
    response = get(page_url, Browser::IPHONE_UA)
    raise ProgrammeDoesNotExist unless response.is_a?(Net::HTTPSuccess)
    self.cookies = response.cookies.join('; ')
    response
  end

  def programme_page_html
    @programme_page_html ||= programme_page.body
  end

  def page_url
    PROGRAMME_URL % pid
  end

  def bugs
    host = URI.parse(page_url)
    (programme_page_html.scan(%r{[^"']+?/o\.gif[^"']+}).map{ |src|
      URI.join(src).to_s
    } + [(BUG_URL % [(rand * 100000).floor])]).uniq
  end

end
end
