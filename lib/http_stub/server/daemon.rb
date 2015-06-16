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
        @configurer = args[:configurer]
        default_args = @configurer ?
          { host: @configurer.stub_server.host, port: @configurer.stub_server.port } : { host: "localhost" }
        super(default_args.merge(args))
      end

      def start!
        super
        if @configurer
          @configurer.initialize!
          logger.info "#{@name} initialized"
        end
      end

      def start_command
        "rake #{@name}:start:foreground"
      end

    end

  end

end
