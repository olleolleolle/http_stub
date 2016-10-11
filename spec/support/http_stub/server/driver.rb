module HttpStub
  module Server

    class Driver

      attr_reader :default_session_id, :host, :port, :uri

      def initialize(name)
        @name = name
        @host = "localhost"
        @port = 8001
        @uri  = "http://#{@host}:#{@port}"
      end

      def start
        @pid = Process.spawn("rake #{@name}:start:foreground --trace")
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
