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

  def filetype
    radio? ? 'mp3' : 'mov'
  end

  def versions
    versions = {}
    REXML::XPath.each(metadata, '//playlist/item') do |node|
      version_pid = node.attributes['identifier']
      next unless version_pid
      alternate = REXML::XPath.first(node, 'alternate')
      versions[alternate.attributes['id']] = version_pid
    end
    versions
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

  def programme_type
    # this could be done more easily if REXML actually worked properly
    REXML::XPath.each(metadata, '//playlist/item') do |node|
      kind = node.attributes['kind']
      return kind if kind
    end
    return nil
  end

  def radio?
    programme_type == 'radioProgramme'
  end

end
end
