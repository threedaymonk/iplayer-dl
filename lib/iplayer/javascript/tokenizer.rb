module IPlayer
module JavaScript
class Tokenizer

  # A very simple JavaScript tokeniser that's just smart enough to handle
  # the code used by the BBC iPlayer version array

  TOKENS = [
    [ %| '([^']+)' |, :string ],
    [ %| "([^"]+)" |, :string ],
    [ %| new \\s+ Date \\s* \\( |, :date ],
    [ %| ([_a-zA-Z][_a-zA-Z0-9]*) |, :identifier ],
    [ %| ([0-9]+) |, :integer ],
    [ %| \\[ |, :array ],
    [ %| \\] |, :close_bracket ],
    [ %| \\{ |, :hash ],
    [ %| \\} |, :close_brace ],
    [ %| :   |, :colon ],
    [ %| ,   |, :comma ],
    [ %| \\. |, :period ],
    [ %| \\) |, :close_parens ],
    [ %| ;   |, :semicolon ],
  ]

  def initialize(source)
    @source = source
  end

  def tokenize
    array = []
    tail = @source
    while tail
      token, data, tail = next_token(tail)
      if token
        array << [token, data].compact
      end
    end
    array
  end

  def next_token(s)
    TOKENS.each do |pattern, name|
      if m = s.match( Regexp.new( "\\A \\s* #{pattern} (.*)", 
                                  Regexp::EXTENDED | Regexp::MULTILINE ))
        if m[2] # if using a capturing group for the data
          return [name, m[1], m[2]]
        else
          return [name, nil,  m[1]]
        end
      end
    end
    return nil
  end

end
end
end

