$:.unshift( File.join( File.dirname(__FILE__), '..', 'lib' ))
require 'test/unit'
require 'iplayer/javascript/tokenizer'

class JavaScriptTokenizerTest < Test::Unit::TestCase
  include IPlayer::JavaScript

  def test_should_tokenize_sample_of_iplayer_javascript
    js = %{
      [
        {
          type      : 'Original', 
          pid       : 'b00b09pv',
          iplayer_broadband_streaming : [
            { start     : new Date(2008, 3, 22, 22, 58, 28),
              end       : new Date(2008, 3, 29, 22, 19, 00) }
          ]
        }
      ]
    }
  
    expected = [ [:array], [:hash], 
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

    tokenizer = Tokenizer.new(js)
    assert_equal expected, tokenizer.tokenize
  end

end
