module HttpStub
  module Client

    class Session

      def initialize(id, server)
        @session_id  = id
        @server      = server
        @description = "session '#{@session_id}'"
      end

      def activate!(*scenario_names)
        parameters = { http_stub_session_id: @session_id, "names[]" => scenario_names }
        @server.submit!(
          method:     :post,
          path:       "scenarios/activate",
          parameters: parameters,
          intent:     "activate scenarios #{scenario_names.map { |name| "'#{name}'" }.join(", ")} in #{@description}"
        )
      end

      def reset!
        @server.submit!(
          method:     :post,
          path:       "stubs/reset",
          parameters: { http_stub_session_id: @session_id },
          intent:     "reset stubs in #{@description}"
        )
      end

      def delete!
        @server.submit!(
          method:     :delete,
          path:       "sessions",
          parameters: { http_stub_session_id: @session_id },
          intent:     "delete #{@description}"
        )
      end

    end

  end
end
