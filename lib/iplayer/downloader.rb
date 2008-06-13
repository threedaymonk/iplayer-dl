module IPlayer
class Downloader
  include IPlayer::Errors

  PROGRAMME_URL = 'http://www.bbc.co.uk/iplayer/page/item/%s.shtml'
  SELECTOR_URL  = 'http://www.bbc.co.uk/mediaselector/3/auth/iplayer_streaming_http_mp4/%s?%s'
  XOR_KEYS       = [0x3c, 0x53]
  XOR_START      = 0x2800
  XOR_END_OFFSET = 0x400

  Version = Struct.new(:name, :pid)

  attr_reader   :browser, :pid
  attr_accessor :cookies, :skip_decryption

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
    html = programme_page.body
    begin
      JavaScript.parse(html[/ iplayer\.versions \s* = \s* ( \[ .*? \] ); /mx, 1])
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
    max = content_range[/\d+$/].to_i
    bytes_got = offset
    yield(bytes_got, max) if block_given?

    xor_end = max - XOR_END_OFFSET

    get(location, Browser::QT_UA, 'Range'=>"bytes=#{offset}-") do |response|
      response.read_body do |data|
        unless skip_decryption
          bytes = data.unpack('C*')
          if bytes_got >= XOR_START && (bytes_got + data.length) < xor_end
            bytes.each_with_index do |d, i|
              offset = bytes_got + i
              bytes[i] = d ^ XOR_KEYS[(offset-XOR_START) & 1]
            end
          else
            bytes.each_with_index do |d, i|
              offset = bytes_got + i
              if (offset >= XOR_START) && (offset < xor_end-2)
                d ^= XOR_KEYS[(offset-XOR_START) & 1]
              elsif (offset >= xor_end-2) && (offset < xor_end)
                d ^= XOR_KEYS[(xor_end-offset+1) & 1]
              end
              bytes[i] = d
            end
          end
          data = bytes.pack('C*')
        end
        bytes_got += data.length
        io << data
        yield(bytes_got, max) if block_given?
      end
    end
  end

private

  def programme_page
    page_url = PROGRAMME_URL % pid
    response = get(page_url, Browser::IPHONE_UA)
    raise ProgrammeDoesNotExist unless response.is_a?(Net::HTTPSuccess)
    self.cookies = response.cookies.join('; ')
    response
  end

end
end
