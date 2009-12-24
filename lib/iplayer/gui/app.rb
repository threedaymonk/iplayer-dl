require 'wx'
require 'iplayer'

module IPlayer
module GUI
class App < Wx::App
  include IPlayer
  include IPlayer::Errors

  def initialize(initial_frame_class, about, options)
    @initial_frame_class = initial_frame_class
    @about = about
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
    @flags = {}
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

    self.yield

    downloader.download(version.pid, path) do |position, max|
      return if check_flag(:stop_download)
      yield position, max
      self.yield
    end
  end

  def stop_download!
    set_flag(:stop_download)
  end

  def get_default_filename(pid)
    self.yield
    begin
      metadata = Metadata.new(pid, @browser)
      title    = metadata.full_title
      filetype = metadata.filetype
    rescue MetadataError
      title    = pid
      filetype = VIDEO_FILETYPE
    end
    "#{ title }.#{ filetype }".gsub(/[^a-z0-9 \-\.]+/i, '')
  end

  def name
    @about[:name]
  end

  def show_about_box
    Wx::about_box(@about)
  end

private
  def set_flag(name)
    @flags[name] = true
  end

  def check_flag(name)
    retval = !!@flags[name]
    @flags.delete(name)
    retval
  end
end
end
end
