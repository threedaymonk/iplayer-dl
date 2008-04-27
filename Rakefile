require 'rubygems'
require 'rake/gempackagetask'
require 'rake/testtask'
require 'zlib'
require 'rake/clean'
require 'rexml/document'

$:.unshift(File.dirname(__FILE__) + '/lib')

CLEAN.include('doc')
SOURCES = FileList['lib/**/*.rb']

task :default => :test

spec = Gem::Specification.new do |s|
	svn_info = REXML::Document.new(`svn info --xml`)

  s.version      = '0.1.' + REXML::XPath.first(svn_info, '//entry').attributes['revision']
  s.name         = 'iplayer-dl'
  s.author       = 'Paul Battley'
  s.email        = 'pbattley@gmail.com'
  s.summary      = 'Libraries and command-line utility for downloading BBC iPlayer videos.'
  s.files        = FileList['{lib,test}/**/*.rb']
  s.require_path = 'lib'
  s.test_file    = 'test/test_all.rb'
  s.has_rdoc     = false
  s.homepage     = 'http://po-ru.com/'
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar_gz = true
end

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/test_*.rb']
  t.verbose = true
end
