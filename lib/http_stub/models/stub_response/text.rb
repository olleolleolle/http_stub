module HttpStub
  module Models
    module StubResponse

      class Text < HttpStub::Models::StubResponse::Base

        add_default_headers "content-type" => "application/json"

        def serve_on(server)
          server.halt(@status, @headers.to_hash, @body)
        end

      end

    end
  end
end
