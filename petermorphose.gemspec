require "#{File.dirname __FILE__}/src/const"

Gem::Specification.new do |s|
  s.name        = "petermorphose"
  s.version     = PM_VERSION
  s.platform    = Gem::Platform::RUBY
  s.author      = "Julian Raschke"
  s.email       = "julian@raschke.de"
  s.homepage    = PM_WEBSITE
  s.summary     = "Peter Morphose, a hectic 2D platformer"
  s.description = "Peter Morphose is a hectic 2D platformer written in Ruby/Gosu."
  
  s.required_rubygems_version = ">= 1.3.7"
  
  s.add_dependency "gosu"
  s.add_dependency "require_relative"
  s.add_development_dependency "releasy"
  
  s.files        = Dir.glob("{bin,src,media,levels}/**/*") + %w(COPYING README.md objects.ini)
  s.executables  << 'petermorphose'
end
