require 'tempfile'

module IPlayer
class Downloader

  IPHONE_URL     = 'http://www.bbc.co.uk/mobile/iplayer/index.html'
  SELECTOR_URL   = 'http://www.bbc.co.uk/mediaselector/3/auth/iplayer_streaming_http_mp4/%s?%s'
  BUG_URL        = 'http://www.bbc.co.uk/iplayer/framework/img/o.gif?%d'
  MAX_SEGMENT    = 4 * 1024 * 1024
  COPY_BUFFER    = 4 * 1024 * 1024

  include IPlayer::Errors

  Version = Struct.new(:name, :pid)

  attr_reader   :browser, :pid
  attr_accessor :cookies

  def self.extract_pid(pid_or_url)
    case pid_or_url
    when %r!/(?:item|episode|programmes)/([a-z0-9]{8})!
      $1
    when %r!^[a-z0-9]{8}$!
      pid_or_url
    when %r!(b0[a-z0-9]{6})!
      $1
    else
      raise NotAPid, pid_or_url
    end
  end

  def initialize(browser, pid)
    @browser = browser
    @pid = pid
  end

  def metadata
    @metadata = Metadata.new(@pid, @browser)
  end

  def get(url, user_agent, options={}, &blk)
    options['User-Agent'] = user_agent
    options['Cookie'] = cookies if cookies
    browser.get(url, options, &blk)
  end
  
  def available_versions
    metadata.versions.map{ |name, vpid| Version.new(name, vpid) }
  end

  def download(version_pid, path, &blk)
    if File.exist?(path)
      offset = File.size(path)
    else
      offset = 0
    end
    
    File.open(path, 'a+b') do |io|    
      location = real_stream_location(version_pid)
      content_length = content_length_from_initial_request(location)
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
  end

private

  def request_iphone_page
    response = get(IPHONE_URL, Browser::IPHONE_UA)
    raise ProgrammeDoesNotExist unless response.is_a?(Net::HTTPSuccess)
    self.cookies = response.cookies.join('; ')
  end

  def request_image_bugs
    get(BUG_URL % [(rand * 100000).floor], Browser::IPHONE_UA)
  end

  def real_stream_location(version_pid)
    request_iphone_page
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
