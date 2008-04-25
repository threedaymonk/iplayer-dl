Dir[ File.join( File.dirname(__FILE__), '*.rb' )].each do |f|
  require File.expand_path(f)
end
