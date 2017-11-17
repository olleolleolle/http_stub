module HttpStub
  module Server

    class Daemon < HttpServerManager::Server

      class << self

        def pid_dir=(dir)
          HttpServerManager.pid_dir = dir
        end

        def log_dir=(dir)
          HttpServerManager.log_dir = dir
        end

      end

      def initialize(args)
        default_args = { host: "localhost", port: args[:configurator].state.port, ping_uri: "/http_stub/status" }
        super(default_args.merge(args))
      end

      def start_command
        "rake #{@name}:start:foreground"
      end

    end

  end

end
