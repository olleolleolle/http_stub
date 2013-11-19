module HttpStub

  class Daemon < HttpServerManager::Server

    class << self

      def pid_dir=(dir)
        HttpServerManager.pid_dir = dir
      end

      def log_dir=(dir)
        HttpServerManager.log_dir = dir
      end

    end

    def initialize(options)
      super({ host: "localhost" }.merge(options))
      @configurer = options[:configurer]
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
