require 'yaml'

module IPlayer
class Preferences

  def initialize(env=ENV, platform=PLATFORM)
    @env      = env
    @platform = platform
    @hash     = {}
    @dirty    = []
    reload
  end

  def reset_defaults
    @hash = {
      'type_preference' => %w[default signed],
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

  def save
    return if @dirty.empty?
    File.open(filename, 'w') do |io|
      io << YAML.dump(dirty_subset)
    end
  end

  def method_missing(msg, *params)
    key = msg.to_s
    if m = key.match(/^([^=]+)=$/)
      key = m[1]
      value = params.first
      unless @hash[key] == value
        @hash[key] = params.first
        @dirty << key
      end
    else
      @hash[key]
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

  def dirty_subset
    @hash.inject({}){ |hash, (k,v)| hash[k] = v if @dirty.include?(k) ; hash }
  end

end
end
