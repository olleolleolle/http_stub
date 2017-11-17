require_relative '../server'
require 'rake/tasklib' unless defined? ::Rake::TaskLib

require 'http_server_manager/rake/task_generators'

require_relative 'server_tasks'
require_relative 'server_daemon_tasks'
