module HttpStub
  module Server
    module Stub
      module Response

        class Text < HttpStub::Server::Stub::Response::Base

          add_default_headers "content-type" => "application/json"

          def serve_on(server)
            server.halt(@status, @headers.to_hash, @body)
          end

        end

      end
    end
  end
end
