module HttpStub
  module Rake

    class ServerTasks < ::Rake::TaskLib

      def initialize(args)
        namespace args[:name] do
          define_start_task(args)
          define_initialize_task(args) if args[:configurer]
        end
      end

      private

      def define_start_task(args)
        namespace :start do
          desc "Start stub #{args[:name]} in the foreground"
          task(:foreground) { run_application(args) }
        end
      end

      def define_initialize_task(args)
        desc "Configure stub #{args[:name]}"
        task(:configure) { args[:configurer].initialize! }
      end

      def run_application(args)
        HttpStub::Server::Application::Application.instance_eval do
          set :environment, :test
          set :port, args[:configurer] ? args[:configurer].stub_server.port : args[:port]
          enable :cross_origin_support if args[:configurer] &&
                                          args[:configurer].stub_server.enabled?(:cross_origin_support)
          run!
        end
      end

    end

  end
end
