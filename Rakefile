require 'rake/testtask'
require 'rake/packagetask'
require 'rake/rdoctask'
require 'rake'
require 'find'
require 'lib/iplayer/version'

# Globals

PKG_NAME = 'iplayer-dl'

PKG_FILES = %w[ COPYING README setup.rb Rakefile ]
Find.find('lib/', 'test/', 'bin/', 'res/') do |f|
  if FileTest.directory?(f) and f =~ /\.svn/
    Find.prune
  else
    PKG_FILES << f
  end
end

EXE_FILES = PKG_FILES + %w[ application.ico init.rb ]

# Tasks

task :default => :test

Rake::TestTask.new do |t|
  t.libs << "test" 
  t.test_files = FileList['test/test_*.rb']
end

Rake::PackageTask.new(PKG_NAME, IPlayer::VERSION) do |p|
  p.need_tar_gz = true
  p.package_files = PKG_FILES
end

task :exe do |t|
  mkdir_p 'tmp'
  build_dir = File.join('tmp', "ipdl-#{IPlayer::GUI_VERSION}")
  rm_rf build_dir
  mkdir build_dir
  EXE_FILES.each do |file|
    next if File.directory?(file)
    loc = File.join(build_dir, File.dirname(file))
    mkdir_p loc
    cp_r file, loc
  end
  sh "ruby rubyscript2exe.rb #{build_dir} --rubyscript2exe-verbose --rubyscript2exe-rubyw"
  rm_rf build_dir
end
