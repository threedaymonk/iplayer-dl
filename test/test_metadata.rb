$:.unshift( File.join( File.dirname(__FILE__), '..', 'lib' ))
require 'test/unit'
require 'iplayer/metadata'
require 'mocha'

class MetadataTest < Test::Unit::TestCase

  def test_should_return_mov_for_tv_filetype
    xml = %{
      <?xml version="1.0" encoding="UTF-8"?>
      <playlist xmlns="http://bbc.co.uk/2008/emp/playlist" revision="1">
        <item kind="programme" duration="5400" identifier="b00ftblc" group="b00ftbxh" publisher="pips">
        </item>
      </playlist>
    }
    pid = 'abc'
    browser = stub(:get => stub(:body => xml))
    metadata = IPlayer::Metadata.new(pid, browser)
    assert_equal 'mov', metadata.filetype
  end

  def test_should_return_mp3_for_radio_filetype
    xml = %{
      <?xml version="1.0" encoding="UTF-8"?>
      <playlist xmlns="http://bbc.co.uk/2008/emp/playlist" revision="1">
        <item kind="radioProgramme" duration="1800" identifier="b00fn3dg" group="b00fn3fp" publisher="pips">
        </item>
      </playlist>
    }
    pid = 'abc'
    browser = stub(:get => stub(:body => xml))
    metadata = IPlayer::Metadata.new(pid, browser)
    assert_equal 'mp3', metadata.filetype
  end

  def test_should_return_hash_of_available_versions_with_version_pids
    xml = %{
      <?xml version="1.0" encoding="UTF-8"?>
      <playlist xmlns="http://bbc.co.uk/2008/emp/playlist" revision="1">
        <item kind="programme" duration="5400" identifier="b00ftblc" group="b00ftbxh" publisher="pips">
          <alternate id="default" />
        </item>
        <item kind="programme" duration="5400" identifier="b00fvy5y" group="b00ftbxh" publisher="pips">
          <alternate id="signed" />
        </item>
      </playlist>
    }
    pid = 'abc'
    browser = stub(:get => stub(:body => xml))
    metadata = IPlayer::Metadata.new(pid, browser)
    expected = {'default' => 'b00ftblc', 'signed' => 'b00fvy5y'}
    assert_equal expected, metadata.versions
  end
end
