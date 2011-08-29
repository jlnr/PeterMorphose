require 'rubygems'
require 'rubygems/package_task'

PM_VERSION = '2.0.2'
GOSU_VERSION = '0.7.36.2'
GOSU_APP_TARBALL = "gosu-mac-wrapper-#{GOSU_VERSION}.tar.gz"
GOSU_APP = 'RubyGosu App.app'
PRETTY_NAME = 'Peter Morphose'

spec = Gem::Specification.new do |s|
  s.name        = "petermorphose"
  s.version     = PM_VERSION
  s.platform    = Gem::Platform::RUBY
  s.author      = "Julian Raschke"
  s.email       = "julian@raschke.de"
  s.homepage    = "https://github.com/jlnr/petermorphose"
  s.summary     = "Peter Morphose, a hectic 2D platformer"
  s.description = "Peter Morphose is a hectic 2D platformer written in Ruby/Gosu."
  
  s.required_rubygems_version = ">= 1.3.7"
  
  s.add_dependency "gosu", "> #{GOSU_VERSION}", "< 0.8"
  s.add_dependency "locale", "~> 2.0"
  s.add_dependency "require_relative"
  
  s.files        = Dir.glob("{bin,src,media,levels}/**/*") + %w(COPYING README.md objects.ini)
  s.executables  << 'petermorphose'
end

Gem::PackageTask.new(spec) do
end

task :release_gem => :package do
  system "gem push 'pkg/petermorphose-#{PM_VERSION}.gem'"
end

file "pkg/#{GOSU_APP_TARBALL}" do
  chdir 'pkg' do
    system "curl -O 'http://libgosu.org/downloads/#{GOSU_APP_TARBALL}'"
  end
end

task :app_contents => "pkg/#{GOSU_APP_TARBALL}" do
  chdir 'pkg' do
    rm_rf GOSU_APP
    rm_rf "#{PRETTY_NAME}.app"
    system "tar xzvf #{GOSU_APP_TARBALL}"
    mv "#{GOSU_APP}", "#{PRETTY_NAME}.app"
  end
  # Game source and content
  cp   'objects.ini', "pkg/#{PRETTY_NAME}.app/Contents/Resources/"
  cp_r Dir['src'],    "pkg/#{PRETTY_NAME}.app/Contents/Resources/"
  cp_r Dir['media'],  "pkg/#{PRETTY_NAME}.app/Contents/Resources/"
  cp_r Dir['levels'], "pkg/#{PRETTY_NAME}.app/Contents/Resources/"
  # Copy locale gem
  locale_lib = File.dirname(`gem which locale`)
  cp_r Dir["#{locale_lib}/*"], "pkg/#{PRETTY_NAME}.app/Contents/Resources/"
  # Stub main.rb that just forwards
  File.open("pkg/#{PRETTY_NAME}.app/Contents/Resources/main.rb", 'w') do |rb|
    rb.puts "require_relative 'src/main'"
  end
end

desc "Update the .app's Info.plist meta information"
task :app_plist do
  require 'plist'
  plist_filename = "pkg/#{PRETTY_NAME}.app/Contents/Info.plist"
  plist = Plist::parse_xml(plist_filename)
  plist['CFBundleIdentifier'] = 'de.petermorphose.PeterMorphose'
  plist['CFBundleVersion'] = PM_VERSION.to_s
  File.open(plist_filename, 'w') { |xml| xml.puts plist.to_plist }
  # TODO Icon
end

desc "Builds pkg/#{PRETTY_NAME}.app"
task :package_app => [:app_contents, :app_plist]

task :release_app => :package_app do
  # TODO zip the .app
  # TODO push to petermorphose.de
end

task :release => [:release_gem, :release_app]
