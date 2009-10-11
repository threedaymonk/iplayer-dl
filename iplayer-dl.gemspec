# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{iplayer-dl}
  s.version = "0.1.16"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Paul Battley"]
  s.date = %q{2009-10-11}
  s.default_executable = %q{iplayer-dl}
  s.email = %q{pbattley@gmail.com}
  s.executables = ["iplayer-dl"]
  s.files = ["COPYING", "README", "setup.rb", "Rakefile", "lib/", "lib/iplayer", "lib/iplayer/version.rb", "lib/iplayer/browser.rb", "lib/iplayer/downloader.rb", "lib/iplayer/preferences.rb", "lib/iplayer/gui", "lib/iplayer/gui/app.rb", "lib/iplayer/gui/main_frame.rb", "lib/iplayer/subtitles.rb", "lib/iplayer/errors.rb", "lib/iplayer/metadata.rb", "lib/iplayer.rb", "test/", "test/test_preferences.rb", "test/test_metadata.rb", "test/test_subtitles.rb", "bin/", "bin/iplayer-dl", "bin/iplayer-dl-gui", "share/", "share/pixmaps", "share/pixmaps/iplayer-dl", "share/pixmaps/iplayer-dl/icon128.png", "share/pixmaps/iplayer-dl/icon48.png", "share/pixmaps/iplayer-dl/icon16.png", "share/pixmaps/iplayer-dl/icon32.png", "share/pixmaps/iplayer-dl/icon64.png"]
  s.homepage = %q{http://po-ru.com/projects/iplayer-downloader}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Download iPlayer content}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<mocha>, [">= 0"])
    else
      s.add_dependency(%q<mocha>, [">= 0"])
    end
  else
    s.add_dependency(%q<mocha>, [">= 0"])
  end
end
