module HttpStub
  module Server
    module Stub

      class RequestBody

        private

        SCHEMA_PROPERTIES = %w{ type definition }.freeze

        public

        class << self

          def create(body)
            matcher = create_schema_request_body(body["schema"]) if body.is_a?(Hash) && body["schema"]
            matcher ||= HttpStub::Server::Stub::SimpleRequestBody.new(body) if !body.blank?
            matcher || HttpStub::Server::Stub::TruthyRequestMatcher
          end

          private

          def create_schema_request_body(schema)
            validate_schema_properties(schema)
            begin
              HttpStub::Server::Stub.const_get("#{schema["type"].capitalize}RequestBody").new(schema["definition"])
            rescue NameError
              raise "Stub request body schema #{schema} is invalid: #{schema["type"]} schema is not supported"
            end
          end

          def validate_schema_properties(schema)
            SCHEMA_PROPERTIES.each do |property|
              raise "Stub request body schema #{schema} is invalid: #{property} expected" unless schema[property]
            end
          end

        end

      end

    end
  end
end
