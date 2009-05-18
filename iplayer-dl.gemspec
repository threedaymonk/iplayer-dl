# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{iplayer-dl}
  s.version = "0.15.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Paul Battley"]
  s.date = %q{2009-05-18}
  s.description = %q{Downloads DRM-free video (h.264) and audio (MP3) files from the BBC iPlayer service by pretending to be an iPhone.}
  s.executables = ["iplayer-dl", "iplayer-dl-gui"]
  s.extra_rdoc_files = [
    "README"
  ]
  s.files = [
    "Rakefile",
    "VERSION.yml",
    "bin/iplayer-dl",
    "bin/iplayer-dl-gui",
    "lib/iplayer.rb",
    "lib/iplayer/browser.rb",
    "lib/iplayer/downloader.rb",
    "lib/iplayer/errors.rb",
    "lib/iplayer/gui/app.rb",
    "lib/iplayer/gui/main_frame.rb",
    "lib/iplayer/metadata.rb",
    "lib/iplayer/preferences.rb",
    "lib/iplayer/subtitles.rb",
    "lib/iplayer/version.rb",
    "test/test_metadata.rb",
    "test/test_preferences.rb",
    "test/test_subtitles.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://po-ru.com/projects/iplayer-downloader/}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.2}
  s.summary = %q{Downloads DRM-free video (h.264) and audio (MP3) files from the BBC iPlayer service by pretending to be an iPhone.}
  s.test_files = [
    "test/test_metadata.rb",
    "test/test_preferences.rb",
    "test/test_subtitles.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
