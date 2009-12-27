require 'rexml/document'
require 'iplayer/errors'
require 'iplayer/constants'

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
    dmy_to_ymd(mixed_title).gsub(/\s*:\s*/, ' - ')
  end

  def filetype
    radio? ? AUDIO_FILETYPE : VIDEO_FILETYPE
  end

  def versions
    versions = {}
    REXML::XPath.each(metadata, '//playlist/item') do |node|
      version_pid = node.attributes['identifier'] or next
      alternate_id = REXML::XPath.first(node, 'alternate').attributes['id'] rescue 'anonymous'
      versions[alternate_id] = version_pid
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

  # convert UK date format to YYYY-MM-DD so that it can be sorted easily
  def dmy_to_ymd(s)
    s.sub(%r[(\d{2})/(\d{2})/(\d{4})], "\\3-\\2-\\1")
  end
end
end
