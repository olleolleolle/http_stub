module HttpStub
  module Server
    module Stub
      module Match
        module Rule

          class SchemaBody

            MANDATORY_ELEMENT_NAMES = %i{ type definition }.freeze

            private_constant :MANDATORY_ELEMENT_NAMES

            class << self

              def create(schema)
                validate(schema)
                begin
                  body_class = HttpStub::Server::Stub::Match::Rule.const_get("#{schema[:type].capitalize}SchemaBody")
                  body_class.new(schema[:definition])
                rescue NameError
                  raise "Stub request body schema #{schema} is invalid: #{schema[:type]} schema is not supported"
                end
              end

              def validate(schema)
                MANDATORY_ELEMENT_NAMES.each do |name|
                  raise "Stub request body schema #{schema} is invalid: #{name} expected" unless schema[name]
                end
              end

            end

          end

        end
      end
    end
  end
end
