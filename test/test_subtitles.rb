$:.unshift( File.join( File.dirname(__FILE__), '..', 'lib' ))
require 'test/unit'
require 'iplayer/subtitles'
require 'mocha'

class SubtitlesTest < Test::Unit::TestCase

  def test_should_return_subtitles_if_found
    selection = %{
      <?xml version="1.0" encoding="UTF-8"?>
      <mediaSelection xmlns="http://bbc.co.uk/2008/mp/mediaselection">
        <media kind="captions" 
          expires="2009-01-31T20:59:00+00:00" 
          type="application/ttaf+xml"   >
          <connection 
            priority="10" 
            kind="http" 
            server="http://www.bbc.co.uk/iplayer/subtitles/" 
            identifier="ng/b00ftjq6_104732850.xml" 
            href="http://www.bbc.co.uk/iplayer/subtitles/ng/b00ftjq6_104732850.xml" 
          />
        </media>
      </mediaSelection>
    }
    expected = 'SUBTITLES'
    browser = stub
    browser.stubs(:get).with('http://www.bbc.co.uk/mediaselector/4/mtis/stream/b00ftjq6').returns(stub(:body => selection))
    browser.stubs(:get).with('http://www.bbc.co.uk/iplayer/subtitles/ng/b00ftjq6_104732850.xml').returns(stub(:body => expected))
    subtitles = IPlayer::Subtitles.new('b00ftjq6', browser)
    assert_equal expected, subtitles.w3c_timed_text 
  end

  def test_should_return_nil_if_no_subtitles_were_found
    selection = %{
      <?xml version="1.0" encoding="UTF-8"?>
      <mediaSelection xmlns="http://bbc.co.uk/2008/mp/mediaselection">
        <media kind="" 
          expires="2009-01-31T20:59:00+00:00" 
          type="video/mpeg" 
          encoding="h264"  >
          <connection 
            priority="10" 
            kind="sis" 
            server="http://www.bbc.co.uk/mediaselector/4/sdp/" 
            identifier="b00ftjq6/iplayer_streaming_n95_3g" 
            href="http://www.bbc.co.uk/mediaselector/4/sdp/b00ftjq6/iplayer_streaming_n95_3g" 
          />
        </media>
      </mediaSelection>
    }
    browser = stub
    browser.stubs(:get).with('http://www.bbc.co.uk/mediaselector/4/mtis/stream/b00ftjq6').returns(stub(:body => selection))
    subtitles = IPlayer::Subtitles.new('b00ftjq6', browser)
    assert_nil subtitles.w3c_timed_text 
  end

end
