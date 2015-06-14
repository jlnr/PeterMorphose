# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/osx'
require 'motion-cocoapods'
require 'motion-yaml'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  
  app.name = 'Peter Morphose'
  
  app.libs << '/usr/local/lib/libSDL2.a'  
  app.pods do
    pod 'Gosu/Gosu', :path => '/Users/jlnr/Projects/Gosu/Gosu'
    pod 'GosuKit', :path => '/Users/jlnr/Projects/Gosu/motion-gosu'
  end
  
  # ...for now
  app.codesign_for_release = false
end
