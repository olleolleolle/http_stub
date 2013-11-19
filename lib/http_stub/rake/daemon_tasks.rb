module HttpStub
  module Rake

    class DaemonTasks < ::Rake::TaskLib

      def initialize(options)
        HttpStub::Rake::ServerTasks.new(options)
        namespace(options[:name]) { HttpServerManager::Rake::ServerTasks.new(HttpStub::Daemon.new(options)) }
      end

    end

  end
end
