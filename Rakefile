require 'rubygems'
require 'bundler/setup'
require 'releasy'
require 'require_relative'
require 'rubygems/package_task'
require_relative 'src/const'

Releasy::Project.new do
  verbose
  
  name "Peter Morphose"
  version PM_VERSION

  executable "src/main.rb"
  files %w(src/**/*.* objects.ini media/**/*.* levels/**/*.*)
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
    executable_type :console
    add_package :exe
  end
end

namespace :gem do
  Gem::PackageTask.new(Gem::Specification.load("petermorphose.gemspec")) do
  end
  
  task :release => :"gem:package" do
    raise "Error: Only do this after the NoMethodError from running 'petermorphose' has been fixed"
    system "gem push 'pkg/petermorphose-#{PM_VERSION}.gem'"
  end
end

task :release => %w(gem:release deploy:osx:app:zip:github deploy:windows:folder:exe:github).map(&:to_sym)
