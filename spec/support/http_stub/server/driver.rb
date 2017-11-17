module HttpStub
  module Server

    class Driver

      DRIVERS = {}

      DEV_NULL = "/dev/null".freeze

      private_constant :DRIVERS, :DEV_NULL

      attr_reader :session_id, :host, :port, :uri, :client

      class << self

        def find_or_create(configurator)
          DRIVERS[configurator] ||= self.new(configurator)
        end

        def all
          DRIVERS.values
        end

      end

      def initialize(configurator)
        @configurator = configurator
        @host     = "localhost"
        @port     = HttpStub::Port.free_port
        @uri      = "http://#{@host}:#{@port}"
        @client   = HttpStub::Client.create(@uri)
      end

      def start
        return if @pid
        @pid = Process.spawn("rake launch_stub configurator=#{@configurator.name} port=#{@port}")
        ::Wait.until!(description: "http stub server for #{@configurator.name} started") do
          Net::HTTP.get_response(@host, "/http_stub/status", @port)
        end
      end

      def session_id=(session_id)
        @session_id = session_id
      end

      def reset_session
        @client.session(@session_id).reset!
      end

      def stop
        Process.kill(9, @pid)
      end

    end

  end
end
