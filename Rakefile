require 'rubygems'
require 'rubygems/package_task'

PM_VERSION = '2.0.1'

spec = Gem::Specification.new do |s|
  s.name        = "petermorphose"
  s.version     = PM_VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Julian Raschke"]
  s.email       = ["julian@raschke.de"]
  s.homepage    = "https://github.com/jlnr/petermorphose"
  s.summary     = "A platformer based "
  s.description = "Bundler manages an application's dependencies through its entire life, across many machines, systematically and repeatably"
  
  s.required_rubygems_version = ">= 1.3.7"
  
  s.add_dependency "gosu", "> 0.7.34", "< 0.8"
  s.add_dependency "locale", "~> 2.0"
  
  s.files        = Dir.glob("{bin,src,media,levels}/**/*") + %w(COPYING README.md objects.ini)
  s.executables  = ['petermorphose']
end

Gem::PackageTask.new(spec) do
end

task :release => :package do
  system "gem push pkg/petermorphose-#{PM_VERSION}.gem"
end
