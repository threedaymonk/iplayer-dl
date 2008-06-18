module IPlayer
class Downloader
  include IPlayer::Errors

  PROGRAMME_URL  = 'http://www.bbc.co.uk/iplayer/page/item/%s.shtml'
  SELECTOR_URL   = 'http://www.bbc.co.uk/mediaselector/3/auth/iplayer_streaming_http_mp4/%s?%s'
  BUG_URL        = 'http://www.bbc.co.uk/iplayer/framework/img/o.gif?%d'

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
    bytes_got = offset
    yield(bytes_got, content_length) if block_given?

    get(location, Browser::QT_UA, 'Range'=>"bytes=#{offset}-#{content_length-1}") do |response|
      response.read_body do |data|
        bytes_got += data.length
        io << data
        yield(bytes_got, content_length) if block_given?
      end
    end
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
