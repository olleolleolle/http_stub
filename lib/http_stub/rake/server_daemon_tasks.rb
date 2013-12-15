module HttpStub
  module Rake

    class ServerDaemonTasks < ::Rake::TaskLib

      def initialize(args)
        HttpStub::Rake::ServerTasks.new(args)
        namespace(args[:name]) { HttpServerManager::Rake::ServerTasks.new(HttpStub::ServerDaemon.new(args)) }
      end

    end

  end
end
