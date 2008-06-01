require 'wx'
require 'iplayer/errors'

module IPlayer
module GUI
class MainFrame < Wx::Frame
  include Wx
  include IPlayer::Errors

  def initialize(app)
    @app = app

    super(nil, -1, @app.name, DEFAULT_POSITION, DEFAULT_SIZE, CAPTION|MINIMIZE_BOX|CLOSE_BOX|SYSTEM_MENU)

    @pid_label = StaticText.new(self, -1, "Programme ID")
    @pid_field = TextCtrl.new(self, -1, "", DEFAULT_POSITION, Size.new(300,-1))
    @pid_field.set_tool_tip("Use either the short alphanumeric programme identifier or the URL of the viewing page on the iPlayer website.")
    @download_progress = Gauge.new(self, -1, 1, DEFAULT_POSITION, DEFAULT_SIZE, GA_HORIZONTAL|GA_SMOOTH)
    @stop_button = Button.new(self, -1, "Stop")
    evt_button(@stop_button.get_id){ |e| stop_button_clicked(e)   }
    @stop_button.disable
    @download_button = Button.new(self, -1, "Download...")
    evt_button(@download_button.get_id){ |e| download_button_clicked(e) }
    @about_button = Button.new(self, -1, "About...")
    evt_button(@about_button.get_id){ |e| about_button_clicked(e) }
    @status_bar = StatusBar.new(self, -1, 0)
    @status_bar.set_fields_count(3)
    @status_bar.set_status_widths([-1, 60, 60])
    set_status_bar(@status_bar)
    @status_bar.set_status_text("Waiting", 0)

    set_properties
    do_layout
  end

  def set_properties
    set_background_colour(SystemSettings.get_colour(SYS_COLOUR_3DFACE))
    self.icon = Icon.new(File.join(File.dirname(__FILE__), '..', '..', '..', 'res', 'icon.png'), BITMAP_TYPE_PNG)
  end

  def do_layout
    sizer_main = BoxSizer.new(VERTICAL)
    sizer_buttons = BoxSizer.new(HORIZONTAL)
    sizer_input = BoxSizer.new(HORIZONTAL)
    sizer_input.add(@pid_label, 0, ALL|ALIGN_CENTER_VERTICAL, 4)
    sizer_input.add(@pid_field, 0, ALL|EXPAND|ALIGN_CENTER_VERTICAL, 4)
    sizer_main.add(sizer_input, 0, EXPAND, 0)
    sizer_main.add(@download_progress, 0, ALL|EXPAND, 4)
    sizer_buttons.add(@about_button, 0, ALL, 4)
    sizer_buttons.add(@stop_button, 0, ALL, 4)
    sizer_buttons.add(@download_button, 0, ALL, 4)
    sizer_main.add(sizer_buttons, 0, ALIGN_RIGHT|ALIGN_CENTER_HORIZONTAL, 0)
    self.set_sizer(sizer_main)
    sizer_main.fit(self)
    layout
    centre
  end

  def stop_button_clicked(event)
    @app.stop_download!
    @status_bar.set_status_text("Stopped", 0)
    @download_button.enable
    @stop_button.disable
  end

  def download_button_clicked(event)
    pid = @pid_field.get_value
    if pid.empty?
      message_box('You must specify a programme ID before I can download it.')
      return
    end
    if pid =~ %r!/item/([a-z0-9]{8})!
      pid = $1
    end

    @download_button.disable
    filename = @app.get_default_filename(pid)

    fd = FileDialog.new(nil, 'Save as', '', filename, 'iPlayer Movies (*.mov)|*.mov', FD_SAVE)

    if fd.show_modal == ID_OK
      path = fd.get_path
      @status_bar.set_status_text(File.basename(path), 0)
      @download_button.disable
      @stop_button.enable
      begin
        @app.download(pid, path) do |position, max|
          @download_progress.set_range(max)
          @download_progress.set_value(position)
          percentage = "%.1f" % [((1000.0 * position) / max).round / 10.0]
          @status_bar.set_status_text("#{(max.to_f / 2**20).round} MiB", 1) 
          @status_bar.set_status_text(percentage+"%", 2) 
        end
      rescue RecognizedError => error
        message_box(error.to_s, :title => 'Error')
      end
      @stop_button.disable
    end
    @download_button.enable
  end

  def about_button_clicked(event)
    @app.show_about_box
  end

  def message_box(message, options={})
    options = {:title => @app.name, :buttons => OK}.merge(options)
    MessageDialog.new(self, message, options[:title], options[:buttons]).show_modal
  end
end
end
end
