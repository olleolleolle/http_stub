module HttpStub
  module Rake

    class ServerTasks < ::Rake::TaskLib

      def initialize(args)
        namespace args[:name] do
          define_start_task(args)
        end
      end

      private

      def define_start_task(args)
        raise "configurator must be specified" unless args[:configurator]
        namespace :start do
          desc "Start stub #{args[:name]} in the foreground"
          task(:foreground) { HttpStub::Server.start(args[:configurator]) }
        end
      end

    end

  end
end
