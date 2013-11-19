require File.expand_path('../../../http_stub', __FILE__)
require 'rake/tasklib' unless defined? (::Rake::TaskLib)

require 'http_server_manager/rake/task_generators'

require File.expand_path('../server_tasks', __FILE__)
require File.expand_path('../daemon_tasks', __FILE__)
