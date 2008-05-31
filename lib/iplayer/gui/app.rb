require 'wx'
require 'iplayer'

module IPlayer
module GUI
class App < Wx::App
  include IPlayer
  include IPlayer::Errors

  def initialize(initial_frame_class, options)
    @initial_frame_class = initial_frame_class
    @options = options
    super()
    if http_proxy = @options[:http_proxy]
      http_proxy = 'http://' + http_proxy unless http_proxy =~ %r{^http://}
      u = URI.parse(http_proxy)
      http = Net::HTTP::Proxy(u.host, u.port)
    else
      http = Net::HTTP
    end
    @browser = Browser.new(http)
    @downloading = false
  end

  def on_init
    @initial_frame_class.new(self).show
  end

  def download(pid, path)
    downloader = Downloader.new(@browser, pid)
    available_versions = downloader.available_versions
    raise MP4Unavailable if available_versions.empty?
    version = available_versions.sort_by{ |v| 
      @options[:type_preference].index(v.name) || 100 
    }.first

    if File.exist?(path)
      offset = File.size(path)
    else
      offset = 0
    end
    self.yield

    File.open(path, 'a+b') do |io|
      @downloading = true
      downloader.download(version.pid, io, offset) do |position, max|
        return unless @downloading
        yield position, max
        self.yield
      end
    end
  end

  def stop_download!
    @downloading = false
  end

  def get_default_filename(pid)
    self.yield
    begin
      title = Metadata.new(pid, @browser).full_title
    rescue MetadataError
      title = pid
    end
    "#{ title }.mov".gsub(/[^a-z0-9 \-\.]+/i, '')
  end
end
end
end
