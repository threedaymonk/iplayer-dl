if defined?(RUBYSCRIPT2EXE)
  app_root = File.expand_path(File.dirname(__FILE__))
  $:.unshift(File.join(app_root, 'lib'))
  if RUBYSCRIPT2EXE.respond_to?(:is_compiling?) && RUBYSCRIPT2EXE.is_compiling?
    require 'iplayer'
    require 'iplayer/gui/app'
    require 'iplayer/gui/main_frame'
    exit
  end
end

load File.join(app_root, 'bin', 'iplayer-dl-gui')
