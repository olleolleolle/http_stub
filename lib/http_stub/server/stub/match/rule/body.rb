module HttpStub
  module Server
    module Stub
      module Match
        module Rule

          class Body

            SCHEMA_PROPERTIES = %w{ type definition }.freeze

            private_constant :SCHEMA_PROPERTIES

            class << self

              def create(body)
                matcher = create_schema_body(body["schema"]) if body.is_a?(Hash) && body["schema"]
                matcher ||= HttpStub::Server::Stub::Match::Rule::SimpleBody.new(body) if body.present?
                matcher || HttpStub::Server::Stub::Match::Rule::Truthy
              end

              private

              def create_schema_body(schema)
                validate_schema_properties(schema)
                begin
                  body_class = HttpStub::Server::Stub::Match::Rule.const_get("#{schema["type"].capitalize}Body")
                  body_class.new(schema["definition"])
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
  end
end
