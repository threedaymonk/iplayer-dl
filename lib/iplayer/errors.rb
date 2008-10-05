module IPlayer
module Errors
  class RecognizedError < RuntimeError
  end

  class ParsingError < RecognizedError
    def to_str
      "Unable to parse the programme page. Perhaps the iPlayer has changed." 
    end
  end

  class OutsideUK < RecognizedError
    def to_str
      "The BBC's geolocation has determined that you are outside the UK.\n"+
      "You can try using a UK proxy."
    end
  end

  class FileUnavailable < RecognizedError
    def to_str
      "An MP4 URL was found, but the download failed."
    end
  end
  
  class MP4Unavailable < RecognizedError
    def to_str
      "This programme is not currently available in an MP4 version."
    end
  end

  class MetadataError < RecognizedError
    def to_str
      "Unable to parse the metadata for this programme.\n"+
      "As a workaround, you can use the -f option to specify a filename manually."
    end
  end

  class ProgrammeDoesNotExist < RecognizedError
    def to_str
      "There is no page for this programme.\n"+
      "This probably means that the programme does not exist."
    end
  end

  class NotAPid < RecognizedError
    def to_str
      "This does not look like a programme ID or a recognised programme URL: "+ message
    end
  end

end
end
