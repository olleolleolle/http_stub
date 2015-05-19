module HttpStub
  module Server
    module StubResponse

      class Base

        private

        DEFAULT_ARGS = { "status" => 200, "delay_in_seconds" => 0 }.freeze

        public

        class << self

          def add_default_headers(headers)
            default_headers.merge!(headers)
          end

          def merge_defaults(args)
            args.clone.tap do |result|
              headers = result["headers"] ||= {}
              DEFAULT_ARGS.each    { |key, value| result[key] = value if !result[key] || result[key] == "" }
              default_headers.each { |key, value| headers[key] = value if !headers[key] || headers[key] == "" }
            end
          end

          private

          def default_headers
            @default_headers ||= {}
          end

        end

        attr_reader :status, :body, :delay_in_seconds, :headers

        def initialize(args={})
          @original_args    = args
          resolved_args     = self.class.merge_defaults(args)
          @status           = resolved_args["status"]
          @body             = resolved_args["body"]
          @delay_in_seconds = resolved_args["delay_in_seconds"]
          @headers          = HttpStub::Server::Headers.new(resolved_args["headers"])
        end

        def empty?
          @original_args.empty?
        end

        def clear
          # Intentionally blank
        end

        def to_s
          @original_args.to_s
        end

      end

    end
  end
end
