module HttpStub
  module Server
    module Stub
      module Response

        class Response

          DEFAULT_ARGS = { status: 200, delay_in_seconds: 0 }.with_indifferent_access.freeze

          private_constant :DEFAULT_ARGS

          attr_reader :status, :body, :headers, :delay_in_seconds, :blocks

          def initialize(args)
            @original_args    = args
            resolved_args     = DEFAULT_ARGS.merge(args)
            @status           = resolved_args[:status]
            @body             = HttpStub::Server::Stub::Response::Body.create(resolved_args)
            @headers          = HttpStub::Server::Stub::Response::Headers.create(resolved_args[:headers], @body)
            @delay_in_seconds = resolved_args[:delay_in_seconds]
            @blocks           = HttpStub::Server::Stub::Response::Blocks.new(resolved_args[:blocks])
          end

          def with_values_from(request)
            self.class.new(@original_args.merge(blocks: []).deep_merge(@blocks.evaluate_with(request)))
          end

          def serve_on(application)
            sleep @delay_in_seconds
            @body.serve(application, self)
          end

          def to_hash
            {
              status:           @status,
              headers:          @headers,
              body:             @body,
              delay_in_seconds: @delay_in_seconds,
              blocks:           @blocks.to_array
            }
          end

          def to_json(*args)
            self.to_hash.to_json(*args)
          end

        end

      end
    end
  end
end
