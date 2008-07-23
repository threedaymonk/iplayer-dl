require 'rexml/document'
require 'iplayer/errors'

module IPlayer
class Metadata
  include IPlayer::Errors

  METADATA_URL = 'http://www.bbc.co.uk/iplayer/playlist/%s'

  def initialize(pid, browser)
    @pid = pid
    @browser = browser
  end

  def title
    mixed_title.split(/:/).first
  end

  def full_title
    mixed_title.gsub(/\s*:\s*/, ' - ')
  end

private

  def metadata
    @metadata ||= REXML::Document.new( @browser.get(METADATA_URL % @pid).body )
  rescue Exception => e
    raise MetadataError, e.message
  end

  def mixed_title
    REXML::XPath.first(metadata, '//playlist/title').text
  end

end
end
