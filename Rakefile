require 'rake/testtask'
require 'rake/packagetask'
require 'rake/rdoctask'
require 'rake'
require 'find'
require 'lib/iplayer/version'

# Globals

PKG_NAME = 'iplayer-dl'

PKG_FILES = %w[ COPYING README setup.rb Rakefile ]
Find.find('lib/', 'test/', 'bin/', 'share/') do |f|
  if FileTest.directory?(f) and File.basename(f) =~ /^\./
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

desc "Build a Windows executable. Needs rubyscript2exe.rb in the current path and the wx gem installed."
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
  mkdir_p 'pkg'
  mv "ipdl-#{IPlayer::GUI_VERSION}.exe", "pkg"
end

begin
  require "rake/gempackagetask"

  spec = Gem::Specification.new do |s|
    # Change these as appropriate
    s.name              = "iplayer-dl"
    s.version           = IPlayer::VERSION
    s.summary           = "Download iPlayer content"
    s.author            = "Paul Battley"
    s.email             = "pbattley@gmail.com"
    s.homepage          = "http://po-ru.com/projects/iplayer-downloader"

    s.has_rdoc          = false

    # Add any extra files to include in the gem
    s.files             = PKG_FILES
    s.executables       = ["iplayer-dl"]

    s.require_paths     = ["lib"]

    # If you want to depend on other gems, add them here, along with any
    # relevant versions
    # s.add_dependency("some_other_gem", "~> 0.1.0")

    # If your tests use any gems, include them here
    if s.respond_to?(:add_development_dependency)
      s.add_development_dependency("mocha")
    end
  end

  # This task actually builds the gem. We also regenerate a static
  # .gemspec file, which is useful if something (i.e. GitHub) will
  # be automatically building a gem for this project. If you're not
  # using GitHub, edit as appropriate.
  Rake::GemPackageTask.new(spec) do |pkg|
    pkg.gem_spec = spec
  end
rescue LoadError
end
