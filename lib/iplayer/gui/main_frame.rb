require 'iplayer/gui/frame'
require 'iplayer/errors'
require 'iplayer/translations'

module IPlayer
module GUI
class MainFrame < Frame
  include IPlayer::Errors
  include Translations
  translation_namespace :gui

  def initialize(app)
    @app = app
    super(nil, -1, @app.name, DEFAULT_POSITION, DEFAULT_SIZE, CAPTION|MINIMIZE_BOX|CLOSE_BOX|SYSTEM_MENU)

    set_properties
    do_layout
  end

  def set_properties
    set_background_colour(SystemSettings.get_colour(SYS_COLOUR_3DFACE))
    relative_icon_path = File.join('share', 'pixmaps', 'iplayer-dl', 'icon32.png')
    icon_path = [
      File.join(File.dirname($0), '..', relative_icon_path),
      File.join(File.dirname(__FILE__), '..', '..', '..', relative_icon_path)
    ].find{ |p| File.exist?(p) }
    self.icon = Icon.new(icon_path, BITMAP_TYPE_PNG) if icon_path
  end

  def do_layout
    sizer_main = v_sizer{ |main|
      main.h_sizer(:flags => EXPAND){ |input|
        input.label(t(:pid), :flags => ALL|ALIGN_CENTER_VERTICAL)
        @pid_field = input.field("",
                     :width    => 300,
                     :tool_tip => t(:pid_tool_tip),
                     :flags    => ALL|EXPAND|ALIGN_CENTER_VERTICAL)
      }
      @download_progress = main.gauge(:flags => ALL|EXPAND)
      main.h_sizer(:flags => ALIGN_RIGHT|ALIGN_CENTER_HORIZONTAL){ |buttons|
        buttons.button(:show_about, t(:about_button))
        @stop_button = buttons.button(:abort_download, t(:stop_button))
        @download_button = buttons.button(:begin_download, t(:download_button))
      }
    }
    status_bar([AUTO, 60, 60])
    self.set_sizer(sizer_main)
    sizer_main.fit(self)
    layout
    centre
    set_status_text(t(:status_waiting), 0)
  end

  def abort_download(event)
    @app.stop_download!
    set_status_text(t(:status_stopped), 0)
    @download_button.enable
    @stop_button.disable
  end

  def begin_download(event)
    pid = @pid_field.get_value
    if pid.empty?
      message_box(t(:no_pid_given))
      return
    else
      begin
        pid = Downloader.extract_pid(pid)
      rescue NotAPid => error
        message_box(error.to_str, :title => 'Error')
        return
      end
    end

    @download_button.disable
    filename = @app.get_default_filename(pid)

    fd = FileDialog.new(nil, t(:save_dialog_title), '', filename, "#{t(:file_types)}|*.mov;*.mp3|", FD_SAVE)

    if fd.show_modal == ID_OK
      path = fd.get_path
      set_status_text(File.basename(path), 0)
      @download_button.disable
      @stop_button.enable
      begin
        @app.download(pid, path) do |position, max|
          @download_progress.set_range(max)
          @download_progress.set_value(position)
          percentage = "%.1f" % [((1000.0 * position) / max).round / 10.0]
          set_status_text("#{(max.to_f / 2**20).round} MiB", 1)
          set_status_text(percentage+"%", 2)
        end
      rescue RecognizedError => error
        message_box(error.to_str, :title => t(:error_title))
      rescue Exception => error
        message_box("#{error.message} (#{error.class})\n#{error.backtrace.first}", :title => t(:error_title))
      end
      @stop_button.disable
    end
    @download_button.enable
  end

  def show_about(event)
    @app.show_about_box
  end

  def message_box(message, options={})
    options = {:title => @app.name, :buttons => OK}.merge(options)
    MessageDialog.new(self, message, options[:title], options[:buttons]).show_modal
  end
end
end
end
