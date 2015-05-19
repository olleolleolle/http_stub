module HttpStub
  module Server
    module StubResponse

      class Text < HttpStub::Server::StubResponse::Base

        add_default_headers "content-type" => "application/json"

        def serve_on(server)
          server.halt(@status, @headers.to_hash, @body)
        end

      end

    end
  end
end
