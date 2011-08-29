require 'rubygems'
require 'rubygems/package_task'

PM_VERSION = '2.0.2'

spec = Gem::Specification.new do |s|
  s.name        = "petermorphose"
  s.version     = PM_VERSION
  s.platform    = Gem::Platform::RUBY
  s.author      = "Julian Raschke"
  s.email       = "julian@raschke.de"
  s.homepage    = "https://github.com/jlnr/petermorphose"
  s.summary     = "Hectic 2D platformer"
  s.description = "A hectic 2D platformer written in Ruby/Gosu."
  
  s.required_rubygems_version = ">= 1.3.7"
  
  s.add_dependency "gosu", "> 0.7.34", "< 0.8"
  s.add_dependency "locale", "~> 2.0"
  s.add_dependency "require_relative"
  
  s.files        = Dir.glob("{bin,src,media,levels}/**/*") + %w(COPYING README.md objects.ini)
  s.executables  << 'petermorphose'
end

Gem::PackageTask.new(spec) do
end

task :release_gem => :package do
  system "gem push pkg/petermorphose-#{PM_VERSION}.gem"
end

task :release => :release_gem
