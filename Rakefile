require 'bundler'
require 'bundler/gem_tasks'
Bundler.require(:default, :development)

require 'rubocop/rake_task'
require 'rspec/core/rake_task'

require_relative 'lib/http_stub/rake/task_generators'
require_relative 'examples/configurer_with_exhaustive_scenarios'
require_relative 'examples/configurer_with_cross_origin_support'

directory "pkg"

desc "Removed generated artefacts"
task :clobber do
  %w{ pkg tmp }.each { |dir| rm_rf dir }
  rm Dir.glob("**/coverage.data"), force: true
  puts "Clobbered"
end

desc "Source code metrics analysis"
RuboCop::RakeTask.new(:metrics) { |task| task.fail_on_error = true }

desc "Exercises specifications"
::RSpec::Core::RakeTask.new(:spec)

desc "Exercises specifications with coverage analysis"
task :coverage => "coverage:generate"

namespace :coverage do

  desc "Generates specification coverage results"
  task :generate do
    ENV["coverage"] = "enabled"
    Rake::Task[:spec].invoke
  end

  desc "Shows specification coverage results in browser"
  task :show do
    begin
      Rake::Task["coverage:generate"].invoke
    ensure
      `open tmp/coverage/index.html`
    end
  end

end

task :validate do
  print " Travis CI Validation ".center(80, "*") + "\n"
  result = `travis-lint #{::File.expand_path('../.travis.yml', __FILE__)}`
  puts result
  print "*" * 80+ "\n"
  raise "Travis CI validation failed" unless $?.success?
end

HttpStub::Server::Daemon.log_dir = ::File.expand_path('../tmp/log', __FILE__)
HttpStub::Server::Daemon.pid_dir = ::File.expand_path('../tmp/pids', __FILE__)

HttpStub::Rake::ServerTasks.new(name: :example_server, port: 8001)

cross_origin_configurer = HttpStub::Examples::ConfigurerWithCrossOriginSupport
cross_origin_configurer.stub_server.host = "localhost"
cross_origin_configurer.stub_server.port = 8001
HttpStub::Rake::ServerDaemonTasks.new(name: :cross_origin_stub, configurer: cross_origin_configurer)

example_configurer = HttpStub::Examples::ConfigurerWithExhaustiveScenarios
example_configurer.stub_server.host = "localhost"
example_configurer.stub_server.port = 8002
HttpStub::Rake::ServerDaemonTasks.new(name: :example_server_daemon, configurer: example_configurer)

task :default => %w{ clobber metrics coverage }

task :pre_commit => %w{ clobber metrics coverage:show validate }
