module Translations
  STRINGS = {
    :gui => {
      :pid               => "Programme ID",
      :stop_button       => "Stop",
      :download_button   => "Download ...",
      :about_button      => "About ...",
      :status_waiting    => "Waiting",
      :pid_tool_tip      => "Use either the short alphanumeric programme identifier or "+
                            "the URL of the viewing page on the iPlayer website.",
      :status_waiting    => "Waiting",
      :no_pid_given      => "You must specify a programme ID before I can download it.",
      :save_dialog_title => "Save As",
      :file_types        => "iPlayer programmes",
      :error_title       => "Error",
    },
    :errors => {
      :OutsideUK =>
        "The BBC's geolocation has determined that you are outside the UK.\n"+
        "You can try using a UK proxy.",
      :FileUnavailable =>
        "The programme file is not currently available.\n"+
        "If it's new, try again later.",
      :MP4Unavailable =>
        "This programme is not currently available in an MP3 or MPEG4 version.",
      :MetadataError =>
        "Unable to parse the metadata for this programme.\n"+
        "As a workaround, you can use the -f option to specify a filename manually.",
      :ProgrammeDoesNotExist =>
        "There is no page for this programme.\n"+
        "This probably means that the programme does not exist.",
      :NotAPid =>
        "This does not look like a programme ID or a recognised programme URL: {{message}}",
    }
  }

  module ClassMethods
    def translation_namespace(ns)
      @translation_namespace = ns
    end

    def get_translation_namespace
      if ancestors[1].respond_to?(:get_translation_namespace)
        ancestors[1].get_translation_namespace
      else
        []
      end + [@translation_namespace]
    end
  end

  def t(key, methods={})
    [self.class.get_translation_namespace, key.to_s].flatten.compact.join(".").split(".").inject(STRINGS){ |hash, subkey|
      hash[subkey.to_sym]
    }.gsub(/\{\{([^\}]+)\}\}/){ methods[$1.to_sym] }
  end

  def self.included(klass)
    klass.extend ClassMethods
  end
end
