require 'wx'
require 'forwardable'

module IPlayer
module GUI
class Frame < Wx::Frame
  include Wx
  extend Forwardable
  AUTO = -1

  class SizerProxy
    def initialize(frame, sizer)
      @frame, @sizer = frame, sizer
    end

    def method_missing(method, *args, &blk)
      default_border =
        case method
        when :h_sizer, :v_sizer
          0
        else
          4
        end
      options    = args.last.is_a?(Hash) ? args.pop : {}
      proportion = options.delete(:proportion) || 0
      flags      = options.delete(:flags) || Wx::ALL
      border     = options.delete(:border) || default_border
      args << options unless options.empty?
      control = @frame.__send__(method, *args, &blk)
      @sizer.add(control, proportion, flags, border)
      control
    end
  end

  def_delegators :@status_bar, :set_status_text

  def sizer(alignment, &blk)
    s = BoxSizer.new(alignment)
    proxy = SizerProxy.new(self, s)
    blk.call(proxy) if block_given?
    s
  end
  def v_sizer(&blk) sizer(VERTICAL, &blk); end
  def h_sizer(&blk) sizer(HORIZONTAL, &blk); end

  def label(text)
    StaticText.new(self, -1, text)
  end

  def field(default_text="", options={})
    width    = options[:width] || -1
    height   = options[:height] || -1
    tool_tip = options[:tool_tip]
    enter    = options[:enter]
    f = TextCtrl.new(self, -1, default_text, DEFAULT_POSITION, Size.new(width, height))
    f.set_tool_tip(tool_tip) if tool_tip
    f
  end

  def gauge
    Gauge.new(self, -1, 1, DEFAULT_POSITION, DEFAULT_SIZE, GA_HORIZONTAL|GA_SMOOTH)
  end

  def button(handler, text)
    b = Button.new(self, -1, text)
    evt_button(b.get_id){ |e| __send__(handler, e) }
    b
  end

  def status_bar(widths)
    @status_bar = StatusBar.new(self, -1, 0)
    @status_bar.set_fields_count(widths.length)
    @status_bar.set_status_widths(widths)
    set_status_bar(@status_bar)
  end
end
end
end
