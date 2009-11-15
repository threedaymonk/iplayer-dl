require 'iplayer/translations'

module IPlayer
module Errors
  class RecognizedError < RuntimeError
    include Translations
    translation_namespace :errors

    def to_str
      t(self.class.name.split("::").last, :message => message)
    end
  end

  [ :ParsingError,
    :OutsideUK,
    :FileUnavailable,
    :MP4Unavailable,
    :MetadataError,
    :ProgrammeDoesNotExist,
    :NotAPid
  ].each do |klass|
    const_set(klass, Class.new(RecognizedError))
  end

end
end
