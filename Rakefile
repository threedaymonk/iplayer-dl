require 'rake/testtask'
require 'rake/packagetask'
require 'rake/rdoctask'
require 'rake'
require 'find'

# Globals

PKG_NAME = 'iplayer-dl'
PKG_VERSION = '0.1.2'

PKG_FILES = ['README', 'setup.rb', 'Rakefile']
Find.find('lib/', 'test/', 'bin/') do |f|
	if FileTest.directory?(f) and f =~ /\.svn/
		Find.prune
	else
		PKG_FILES << f
	end
end

# Tasks

task :default => :test

Rake::TestTask.new do |t|
	t.libs << "test" 
	t.test_files = FileList['test/test_*.rb']
end

Rake::PackageTask.new(PKG_NAME, PKG_VERSION) do |p|
	p.need_tar_gz = true
	p.package_files = PKG_FILES
end
