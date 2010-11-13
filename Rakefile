# -*- ruby -*-
$:.unshift(File.dirname(__FILE__)+"/lib")
require 'rubygems'
require 'hoe'
require 'extendmatrix'

require 'rspec'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = ["-c", "-f progress"]
  t.pattern = 'spec/**/*_spec.rb'
end



Hoe.plugin :git
Hoe.spec 'extendmatrix' do
  self.testlib=:rspec
  self.test_globs="spec/*_spec.rb"
  self.rubyforge_name = 'ruby-statsample'
  self.version = Matrix::EXTENSION_VERSION
  self.developer('Cosmin Bonchis', 'cbonchis_info.uvt.ro')
end

# vim: syntax=ruby
