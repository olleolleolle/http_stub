module HttpStub
  module Rake

    class ServerDaemonTasks < ::Rake::TaskLib

      def initialize(options)
        HttpStub::Rake::ServerTasks.new(options)
        namespace(options[:name]) { HttpServerManager::Rake::ServerTasks.new(HttpStub::ServerDaemon.new(options)) }
      end

    end

  end
end
