# -*- ruby -*-
$:.unshift(File.dirname(__FILE__)+"/lib")
require 'rubygems'
require 'hoe'
require 'version'

require 'rspec'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = ["-c", "-f progress"]
  t.pattern = 'spec/**/*_spec.rb'
end
# vim: syntax=ruby
