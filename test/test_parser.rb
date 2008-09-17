$:.unshift( File.join( File.dirname(__FILE__), '..', 'lib' ))
require 'test/unit'
require 'iplayer/javascript/parser'

class JavaScriptParserTest < Test::Unit::TestCase
  include IPlayer::JavaScript

  def test_should_convert_tokens_to_ruby_data_structure
    tokens = [ [:array], [:hash], 
      [:identifier, "type"], [:colon], [:string, "Original"], [:comma], 
      [:identifier, "pid"], [:colon], [:string, "b00b09pv"], [:comma], 
      [:identifier, "iplayer_broadband_streaming"], [:colon], [:array], [:hash], 
        [:identifier, "start"], [:colon], 
          [:date], 
            [:integer, "2008"], [:comma], [:integer, "3"], [:comma], 
            [:integer, "22"], [:comma], [:integer, "22"], [:comma], 
            [:integer, "58"], [:comma], [:integer, "28"], 
          [:close_parens], [:comma], 
        [:identifier, "end"], [:colon], 
          [:date], 
            [:integer, "2008"], [:comma], [:integer, "3"], [:comma], 
            [:integer, "29"], [:comma], [:integer, "22"], [:comma], 
            [:integer, "19"], [:comma], [:integer, "00"], 
          [:close_parens], 
      [:close_brace], [:close_bracket], 
    [:close_brace], [:close_bracket] ]

    expected = [{
      :type => "Original",
      :pid  => "b00b09pv",
      :iplayer_broadband_streaming => [{ 
        :start => DateTime.civil(2008, 4, 22, 22, 58, 28), 
        :end   => DateTime.civil(2008, 4, 29, 22, 19, 00) 
      }]
    }]

    assert_equal expected, Parser.new(tokens).parse
  end
end


