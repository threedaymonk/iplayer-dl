module IPlayer
module Errors
  ParsingError    = Class.new(RuntimeError)
  FileUnavailable = Class.new(RuntimeError)
  MP4Unavailable  = Class.new(RuntimeError)
  MetadataError   = Class.new(RuntimeError)
end
end
