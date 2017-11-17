module HttpStub
  module Server
    module Stub
      module Match
        module Rule

          class JsonSchemaBody

            def initialize(schema_definition)
              @schema_definition = schema_definition
            end

            def matches?(request, logger)
              validate_against_schema(request).tap do |errors|
                errors.each { |error| logger.info(error) }
              end.empty?
            end

            def to_s
              @schema_definition.to_json
            end

            private

            def validate_against_schema(request)
              JSON::Validator.fully_validate(@schema_definition, request.body, validate_schema: true, json: true)
            rescue StandardError => err
              [ err.message ]
            end

          end

        end
      end
    end
  end
end
