require 'date'

module IPlayer
module JavaScript
class Parser

  # In conjunction with the tokeniser, this parser will turn the BBC iPlayer
  # version array into a corresponding Ruby data structure. It assumes that the
  # original data is well-formed.

  attr_reader :tokens

  def initialize(tokens)
    @tokens = tokens
  end

  def next_token
    tokens[0][0] rescue nil
  end 
  
  def parse
    token, data = tokens.shift
    parse_one(token, data)
  end

  def parse_one(token, data)
    case token
    when :string
      data
    when :date
      parse_date
    when :identifier
      data.to_sym
    when :array
      parse_array
    when :hash
      parse_hash
    when :integer
      data.to_i
    else
      data
    end
  end

  def parse_list(terminator)
    array = []
    loop do
      token, data = tokens.shift
      case token
      when terminator
        return array
      when :comma
        # skip element separators
      else
        array << parse_one(token, data)
      end
    end
  end

  def parse_array
    parse_list(:close_bracket)
  end

  def parse_date
    digits = parse_list(:close_parens)
    digits[1] += 1 # January is 0 in JS, but 1 in Ruby (and reality)
    DateTime.civil(*digits)
  end

  def parse_hash
    hash = {}
    key = nil
    loop do
      token, data = tokens.shift
      case token
      when :close_brace
        return hash
      when :comma, :colon
        # skip element separators
      else
        a = parse_one(token, data)
        if key
          hash[key] = a
          key = nil
        else
          key = a
        end
      end
    end
  end

end
end
end
