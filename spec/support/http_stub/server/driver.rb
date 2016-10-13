module HttpStub
  module Server

    class Driver

      DRIVERS = {}

      private_constant :DRIVERS

      attr_reader :default_session_id, :host, :port, :uri

      class << self

        def find_or_create(specification)
          resolved_specification = { name: "example_server", port: 8001 }.merge(specification)
          DRIVERS[resolved_specification] ||= self.new(resolved_specification)
        end

        def all
          DRIVERS.values
        end

      end

      def initialize(specification)
        @name = specification[:name]
        @host = "localhost"
        @port = specification[:port]
        @uri  = "http://#{@host}:#{@port}"
      end

      def start
        return if @pid
        @pid = Process.spawn("rake #{@name}:start:foreground", out: "/dev/null", err: "/dev/null")
        ::Wait.until!(description: "http stub server #{@name} started") do
          Net::HTTP.get_response(@host, "/", @port)
        end
      end

      def default_session_id=(session_id)
        @default_session_id = session_id
        HTTParty.post("#{@uri}/http_stub/sessions/default", body: { http_stub_session_id: session_id })
      end

      def reset_session
        HTTParty.post("#{@uri}/http_stub/stubs/reset", body: { http_stub_session_id: @default_session_id })
      end

      def stop
        Process.kill(9, @pid)
      end

    end

  end
end
