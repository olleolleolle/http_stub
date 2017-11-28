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
        @host         = "localhost"
      end

      def start!
        return if started?
        ::Wait.until!(description: "server on an available port started") do
          @port = HttpStub::Port.free_port
          @pid = Process.spawn("rake launch_server configurator=#{@configurator.name} port=#{@port}", out: DEV_NULL,
                                                                                                      err: DEV_NULL)
          ::Wait.until!(description: "http stub server for #{@configurator.name} started", timeout_in_seconds: 3) do
            Net::HTTP.get_response(@host, "/http_stub/status", @port)
            @uri    = "http://#{@host}:#{@port}"
            @client = HttpStub::Client.create(@uri)
          end
        end
      end

      def stop!
        Process.kill(9, @pid) if started?
      end

      private

      def started?
        !!@client
      end

    end

  end
end
