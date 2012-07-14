require 'rubygems'
require 'bundler/setup'
require 'releasy'
require 'require_relative'
require 'rubygems/package_task'
require_relative 'src/const'

Releasy::Project.new do
  name "Peter Morphose"
  version PM_VERSION

  executable "bin/petermorphose"
  files %w(objects.ini src/**/* media/**/* levels/**/*)
  exposed_files %w(README.md COPYING)
  add_link PM_WEBSITE, PM_WEBSITE_DESC
  exclude_encoding

  add_build :osx_app do
    url "de.petermorphose.PeterMorphose"
    wrapper "wrappers/gosu-mac-wrapper-0.7.41.tar.gz" # Assuming this is where you downloaded this file.
    icon "media/PeterMorphose.icns"
    add_package :zip
  end

  add_build :windows_folder do
    icon "media/PeterMorphose.ico"
    executable_type :windows
    add_package :exe
  end

  add_deploy :github # Upload to a github project.
end

spec = eval File.read("petermorphose.gemspec")

Gem::PackageTask.new(spec) do
end

task :release_gem => :package do
  system "gem push 'pkg/petermorphose-#{PM_VERSION}.gem'"
end

task :release => [:release_gem, :"deploy:osx:app:zip:github", :"deploy:windows:folder:exe:github"]
