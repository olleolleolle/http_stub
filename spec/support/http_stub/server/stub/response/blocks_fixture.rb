module HttpStub
  module Server
    module Stub
      module Response

        class BlocksFixture

          class << self

            def simple
              lambda do
                {
                  status:           200,
                  headers:          HttpStub::HeadersFixture.many,
                  body:             "simple content",
                  delay_in_seconds: 8
                }
              end
            end

            def containing(value)
              lambda do
                {
                  status:           201,
                  headers:          HttpStub::HeadersFixture.many,
                  body:             "value provided = #{value}",
                  delay_in_seconds: 18
                }
              end
            end

            def with_request_interpolation
              lambda do |request|
                {
                  status:           200,
                  headers:          HttpStub::HeadersFixture.many,
                  body:             "parameter[:some_parameter] = #{request.parameters[:some_parameter]}",
                  delay_in_seconds: 28
                }
              end
            end

            def many
              [ simple, containing("some value"), with_request_interpolation ]
            end

          end

        end

      end
    end
  end
end
