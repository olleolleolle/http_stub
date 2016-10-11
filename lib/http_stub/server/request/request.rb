module HttpStub
  module Server
    module Request

      class Request

        delegate :base_uri, :uri, :method, :headers, :parameters, :body, :to_json, to: :@sinatra_request

        attr_reader :session_id, :session

        def initialize(sinatra_request, session_id, session)
          @sinatra_request = sinatra_request
          @session_id      = session_id
          @session         = session
        end

      end

    end
  end
end
