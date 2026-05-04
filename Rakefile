require 'rubygems'
require 'bundler/setup'
require 'rubygems/package_task'
require_relative 'src/const'

namespace :gem do
  Gem::PackageTask.new(Gem::Specification.load("petermorphose.gemspec")) do
  end
  
  task :release => :"gem:package" do
    raise "Error: Only do this after the NoMethodError from running 'petermorphose' has been fixed"
    system "gem push 'pkg/petermorphose-#{PM_VERSION}.gem'"
  end
end
