require 'tempfile'

module IPlayer
class Downloader

  PROGRAMME_URL  = 'http://www.bbc.co.uk/iplayer/page/item/%s.shtml'
  SELECTOR_URL   = 'http://www.bbc.co.uk/mediaselector/3/auth/iplayer_streaming_http_mp4/%s?%s'
  BUG_URL        = 'http://www.bbc.co.uk/iplayer/framework/img/o.gif?%d'
  MAX_SEGMENT    = 4 * 1024 * 1024
  COPY_BUFFER    = 4 * 1024 * 1024

  include IPlayer::Errors

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
  
  def available_versions
    versions.inject([]){ |av, version|
      if (version[:iplayer_streaming_http_mp4].any?{ |stream|
        stream[:start] < DateTime.now && stream[:end] > DateTime.now })
        av << Version.new(version[:type], version[:pid])
      end
      av
    }
  end

  def download(version_pid, io, initial_offset=0, &blk)
    location = real_stream_location(version_pid)
    content_length = content_length_from_initial_request(location)
    offset = initial_offset
    yield(offset, content_length) if block_given?

    offset.step(content_length - 1, MAX_SEGMENT) do |first_byte|
      last_byte = [first_byte + MAX_SEGMENT - 1, content_length - 1].min
      get(location, Browser::QT_UA, 'Range'=>"bytes=#{first_byte}-#{last_byte}") do |response|
        response.read_body do |data|
          offset += data.length
          io << data
          yield(offset, content_length) if block_given?
        end
      end
    end
  end

private

  def versions
    begin
      JavaScript.parse(programme_page_html[/ iplayer\.versions \s* = \s* ( \[ .*? \] ); /mx, 1])
    rescue 
      raise ParsingError
    end
  end

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

  def request_image_bugs
    host = URI.parse(page_url)
    bugs = (programme_page_html.scan(%r{[^"']+?/o\.gif[^"']+}).map{ |src|
      URI.join(src).to_s
    } + [(BUG_URL % [(rand * 100000).floor])]).uniq
    bugs.each do |url|
      get(url, Browser::IPHONE_UA)
    end
  end

  def real_stream_location(version_pid)
    request_image_bugs

    # Get the auth URL
    r = (rand * 10000000).floor
    selector = SELECTOR_URL % [version_pid, r]
    response = get(selector, Browser::QT_UA, 'Range'=>'bytes=0-1')
    
    # It redirects us to the real stream location
    location = response.to_hash['location']
    if location =~ /error\.shtml/
      raise FileUnavailable
    end
    return location
  end

  def content_length_from_initial_request(location)
    # The first request of CoreMedia is always for the first byte
    response = get(location, Browser::QT_UA, 'Range'=>'bytes=0-1')

    # We now know the full length of the content
    content_range = response.to_hash['content-range']
    unless content_range
      raise FileUnavailable
    end
    return content_range[/\d+$/].to_i
  end

end
end
