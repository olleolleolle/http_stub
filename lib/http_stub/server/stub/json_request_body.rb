module HttpStub
  module Server
    module Stub

      class JsonRequestBody

        def initialize(schema_definition)
          @schema_definition = schema_definition
        end

        def match?(request)
          validate_against_schema(request).tap do |errors|
            errors.each { |error| request.logger.info(error) }
          end.empty?
        end

        def to_s
          @schema_definition.to_json
        end

        private

        def validate_against_schema(request)
          begin
            JSON::Validator.fully_validate(@schema_definition, request.body.read, validate_schema: true, json: true)
          rescue Exception => exc
            [ exc.message ]
          end
        end

      end

    end
  end
end
