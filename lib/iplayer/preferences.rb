require 'yaml'

module IPlayer
class Preferences

  def initialize(env=ENV, platform=PLATFORM)
    @env      = env
    @platform = platform
    @hash     = {}
    reload
  end

  def reset_defaults
    @hash = {
      'type_preference' => %w[original signed],
      'download_path'   => Dir.pwd,
      'http_proxy'      => @env['http_proxy'],
      'subdirs'         => false
    }
  end

  def reload
    reset_defaults
    return unless File.exist?(filename)
    @hash.merge!( YAML.load(File.read(filename)) || {} )
  end

  def method_missing(msg, *params)
    message = msg.to_s
    if m = message.match(/^([^=]+)=$/)
      @hash[m[1]] = params.first
    else
      @hash[message]
    end
  end

  def inspect(*args)
    "#<IPlayer::Preferences #{ @hash.map{ |k,v| "#{k}=#{v.inspect}" }.join(', ') }>"
  end

private

  def filename
    case @platform
    when /mswin/i
      File.join(@env['APPDATA'], 'iplayer-dl')
    else
      File.join(@env['HOME'], '.iplayer-dl')
    end
  end

end
end
