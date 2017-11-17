require 'bundler'
require 'bundler/gem_tasks'
Bundler.require(:default, :development)

require 'rubocop/rake_task'
require 'rspec/core/rake_task'

require_relative 'lib/http_stub/rake/task_generators'

require_relative 'lib/http_stub/configurator'

require_relative 'examples/stub_builder'
Dir[File.expand_path('../examples/**/*.rb', __FILE__)].each { |file| require file }

directory "pkg"

desc "Removed generated artefacts"
task :clobber do
  %w{ pkg tmp }.each { |dir| rm_rf dir }
  rm Dir.glob("**/coverage.data"), force: true
  puts "Clobbered"
end

desc "Source code metrics analysis"
RuboCop::RakeTask.new(:metrics) { |task| task.fail_on_error = true }

desc "Provisions specification dependencies"
task :provision do
  sh "provisioning/install_geckodriver.sh"
end

desc "Launches a server for test purposes"
task :launch_server do
  configurator = ENV["configurator"].constantize
  configurator.stub_server.port = ENV["port"].to_i
  HttpStub::Server.start(configurator)
end

desc "Exercises specifications"
::RSpec::Core::RakeTask.new(:spec)

desc "Exercises specifications with coverage analysis"
task coverage: "coverage:generate"

namespace :coverage do

  desc "Generates specification coverage results"
  task :generate do
    ENV["coverage"] = "enabled"
    Rake::Task[:spec].invoke
    sh "bundle exec codeclimate-test-reporter" if ENV["CODECLIMATE_REPO_TOKEN"]
  end

  desc "Shows specification coverage results in browser"
  task :show do
    begin
      Rake::Task["coverage:generate"].invoke
    rescue Exception => exc
      `open tmp/coverage/index.html`
      raise exc
    end
  end

end

task :validate do
  print " Travis CI Validation ".center(80, "*") + "\n"
  result = `travis-lint #{::File.expand_path('../.travis.yml', __FILE__)}`
  puts result
  print "*" * 80 + "\n"
  raise "Travis CI validation failed" unless $?.success?
end

HttpStub::Server::Daemon.log_dir = ::File.expand_path('../tmp/log', __FILE__)
HttpStub::Server::Daemon.pid_dir = ::File.expand_path('../tmp/pids', __FILE__)

example_configurator = HttpStub::Examples::ConfiguratorWithExhaustiveScenarios
example_configurator.stub_server.port = 8001
HttpStub::Rake::ServerTasks.new(name: :example_server, configurator: example_configurator)
HttpStub::Rake::ServerDaemonTasks.new(name: :example_server_daemon, configurator: example_configurator)

task pre_commit: %w{ clobber metrics coverage:show validate }

task default: :pre_commit

task commit: %w{ clobber metrics provision coverage }
