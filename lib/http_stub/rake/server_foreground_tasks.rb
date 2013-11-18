module HttpStub

  module Rake

    class ServerForegroundTasks < ::Rake::TaskLib

      def initialize(options)
        namespace options[:name] do
          define_start_task(options)
          define_initialize_task(options) if options[:configurer]
        end
      end

      private

      def define_start_task(options)
        namespace :start do
          desc "Starts stub #{options[:name]} in the foreground"
          task(:foreground) do
            HttpStub::Server.instance_eval do
              set :environment, :test
              set :port, options[:port]
              run!
            end
          end
        end
      end

      def define_initialize_task(options)
        desc "Configures stub #{options[:name]}"
        task(:configure) { options[:configurer].initialize! }
      end

    end

  end

end
