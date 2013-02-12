require File.expand_path('../../../http_stub', __FILE__)
require 'rake/tasklib' unless defined?(::Rake::TaskLib)

module Http
  module Stub

    class StartServerRakeTask < ::Rake::TaskLib

      def initialize(options)
        desc "Starts stub #{options[:name]}"
        task "start_#{options[:name]}" do
          Http::Stub::Server.instance_eval do
            set :port, options[:port]
            run!
          end
        end
      end

    end

  end
end
