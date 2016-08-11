module HttpStub
  module Server
    module Stub
      module Response

        class Base

          DEFAULT_ARGS = { "status" => 200, "delay_in_seconds" => 0 }.freeze

          private_constant :DEFAULT_ARGS

          class << self

            def add_default_headers(headers)
              default_headers.merge!(headers)
            end

            def merge_defaults(args)
              args.clone.tap do |result|
                headers = result["headers"] ||= {}
                DEFAULT_ARGS.each    { |key, value| result[key]  = value if !result[key]  || result[key]  == "" }
                default_headers.each { |key, value| headers[key] = value if !headers[key] || headers[key] == "" }
              end
            end

            private

            def default_headers
              @default_headers ||= {}
            end

          end

          attr_reader :status, :headers, :delay_in_seconds

          def initialize(args={})
            @original_args    = args
            resolved_args     = self.class.merge_defaults(args)
            @status           = resolved_args["status"]
            @headers          = HttpStub::Server::Stub::Response::Attribute::Headers.new(resolved_args["headers"])
            @delay_in_seconds = resolved_args["delay_in_seconds"]
          end

          def type
            self.class.name.demodulize.underscore
          end

          def to_hash
            { status: @status, headers: @headers, delay_in_seconds: @delay_in_seconds }
          end

          def to_json(*args)
            self.to_hash.to_json(*args)
          end

        end

      end
    end
  end
end
