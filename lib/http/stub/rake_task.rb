require File.expand_path('../../../http_stub', __FILE__)
require 'rake/tasklib' unless defined?(::Rake::TaskLib)

module Http
  module Stub

    class RakeTask < ::Rake::TaskLib

      def initialize(server_name, server_port)
        desc "Starts stub #{server_name} server"
        task "start_#{server_name}_server" do
          Http::Stub::Server.instance_eval do
            set :port, server_port
            run!
          end
        end
      end

    end

  end
end
