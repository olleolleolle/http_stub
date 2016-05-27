module HttpStub
  module Server
    module Stub
      module Response

        class Text < HttpStub::Server::Stub::Response::Base

          add_default_headers "content-type" => "application/json"

          attr_reader :body

          def initialize(args={})
            super
            @body = HttpStub::Server::Stub::Response::Attribute::Body.new(args["body"])
          end

          def with_values_from(request)
            self.class.new(@original_args.merge("headers" => @headers.with_values_from(request),
                                                "body"    => @body.with_values_from(request)))
          end

          def serve_on(server)
            server.halt(@status, @headers.to_hash, @body)
          end

        end

      end
    end
  end
end
