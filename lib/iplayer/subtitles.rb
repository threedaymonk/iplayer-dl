require 'rexml/document'
require 'iplayer/errors'

module IPlayer
class Subtitles
  include IPlayer::Errors

  SELECTOR_URL = 'http://www.bbc.co.uk/mediaselector/4/mtis/stream/%s'

  def initialize(version_pid, browser)
    @version_pid = version_pid
    @browser = browser
  end

  def w3c_timed_text
    url = subtitle_url
    return nil unless url
    @browser.get(url).body
  end

private

  def subtitle_url
    selection = REXML::Document.new( xml = @browser.get(SELECTOR_URL % @version_pid).body )
    REXML::XPath.each(selection, '//media') do |node|
      if node.attributes['kind'] == 'captions'
        return REXML::XPath.first(node, 'connection').attributes['href']
      end
    end
    nil
  end
end
end
