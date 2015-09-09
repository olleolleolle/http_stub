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
          task(:foreground) do
            HttpStub::Server::Application.instance_eval do
              set :environment, :test
              set :port, args[:configurer] ? args[:configurer].stub_server.port : args[:port]
              run!
            end
          end
        end
      end

      def define_initialize_task(args)
        desc "Configure stub #{args[:name]}"
        task(:configure) { args[:configurer].initialize! }
      end

    end

  end
end
