module IPlayer
module Errors
  class ParsingError < RuntimeError
    def to_s
      "Unable to parse the programme page. Possible reasons:\n"+
      "1. The iPlayer has changed\n"+ 
      "2. You are outside the UK (and not using a UK proxy).\n"+
      "3. The BBC think that you are outside the UK."
    end
  end

  class FileUnavailable < RuntimeError
    def to_s
      "An MP4 URL was found, but the download failed."
    end
  end
  
  class MP4Unavailable < RuntimeError
    def to_s
      "This programme is not currently available in an MP4 version."
    end
  end

  class MetadataError < RuntimeError
    def to_s
      "Unable to parse the metadata for this programme.\n"+
      "As a workaround, you can use the -f option to specify a filename manually."
    end
  end
end
end
