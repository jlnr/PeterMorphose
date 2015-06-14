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
    pod 'Gosu/Gosu', :git => 'https://github.com/gosu/gosu'
    pod 'GosuKit', :git => 'https://github.com/gosu/motion-gosu'
  end
  
  # ...for now
  app.codesign_for_release = false
end
