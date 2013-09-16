module HttpStub

  module Rake

    class ServerTasks < ::Rake::TaskLib

      def initialize(options)
        define_start_task(options)
        define_initialize_task(options) if options[:configurer]
      end

      private

      def define_start_task(options)
        desc "Starts stub #{options[:name]}"
        task "start_#{options[:name]}" do
          HttpStub::Server.instance_eval do
            set :port, options[:port]
            run!
          end
        end
      end

      def define_initialize_task(options)
        desc "Configures stub #{options[:name]}"
        task("configure_#{options[:name]}") { options[:configurer].initialize! }
      end

    end

  end

end
