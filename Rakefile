require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'spec/rake/spectask'
require 'selenium/rake/tasks'

task :default => :spec

Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_opts = ['--options', "\"#{File.dirname(__FILE__)}/spec/spec.opts\""]
end

namespace :selenium do
  Selenium::Rake::RemoteControlStartTask.new(:start) do |rc|
    rc.port = 4444
    rc.timeout_in_seconds = 3 * 60
    rc.background = true
    rc.wait_until_up_and_running = true
    rc.jar_file = File.expand_path(File.join(File.dirname(__FILE__), "vendor", "selenium-server", "selenium-server.jar"))
    rc.additional_args << "-singleWindow"
  end

  Selenium::Rake::RemoteControlStopTask.new(:stop) do |rc|
    rc.host = "localhost"
    rc.port = 4444
    rc.timeout_in_seconds = 3 * 60
  end
end
