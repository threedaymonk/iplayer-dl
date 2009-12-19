require 'cgi'

module IPlayer
class Downloader

  EPISODE_URL    = 'http://www.bbc.co.uk/mobile/iplayer/episode/%s'
  SELECTOR_URL   = 'http://www.bbc.co.uk/mediaselector/3/auth/iplayer_streaming_http_mp4/%s?%s'
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
    response = browser.get(url, options, &blk)
    self.cookies = response.cookies.join('; ')
    response
  end

  def post(url, data, user_agent, options={}, &blk)
    options['User-Agent'] = user_agent
    options['Cookie'] = cookies if cookies
    response = browser.post(url, data, options, &blk)
    self.cookies = response.cookies.join('; ')
    response
  end

  def available_versions
    metadata.versions.map{ |name, vpid| Version.new(name, vpid) }
  end

  def download(version_pid, path, options={}, &blk)
    if options[:subtitles]
      download_subtitles(version_pid, path)
    end

    if File.exist?(path)
      offset = File.size(path)
    else
      offset = 0
    end

    File.open(path, 'a+b') do |io|
      location = real_stream_location(@pid)
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

  def request_episode_page(pid)
    response = get(EPISODE_URL % pid, Browser::IPHONE_UA)
    raise ProgrammeDoesNotExist unless response.is_a?(Net::HTTPSuccess)
    if response.body =~ /isOver\d+/
      data = "form=guidanceprompt&#$&=1"
      response = post(EPISODE_URL % pid, data, Browser::IPHONE_UA)
      raise ProgrammeDoesNotExist unless response.is_a?(Net::HTTPSuccess)
    end
    response.body
  end

  def real_stream_location(pid)
    html = request_episode_page(pid)
    location = html[%r{<embed[^>]*?href="(http://[^"]+)}, 1]

    unless location
      raise FileUnavailable
    end

    # The Beeb appear not to believe in escaping URLs, but let's unescape them in case they have an outbreak of standards compliance:
    CGI.unescapeHTML(location)
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

  def download_subtitles(version_pid, media_path)
    subtitles = Subtitles.new(version_pid, browser)
    xml = subtitles.w3c_timed_text
    return if xml.nil?
    subtitles_path = media_path.sub(/\.[^\.]+$/, '.xml')
    return if File.exist?(subtitles_path)
    File.open(subtitles_path, 'w') do |f|
      f << xml
    end
  end
end
end
