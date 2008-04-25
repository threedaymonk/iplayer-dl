require 'javascript/tokenizer'
require 'javascript/parser'

module IPlayer
module JavaScript

  def self.parse(js)
    tokens = Tokenizer.new(js).tokenize
    Parser.new(tokens).parse
  end

end
end
