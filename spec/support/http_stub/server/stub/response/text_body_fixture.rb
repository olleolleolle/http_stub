module HttpStub
  module Server
    module Stub
      module Response

        class TextBodyFixture

          class << self

            def args_with_body
              { body: "some text" }
            end

            def args_with_json(json_value="some json")
              { json: ObjectConvertableToJson.new(json_value) }
            end

            def json
              HttpStub::Server::Stub::Response::TextBody.new(args_with_json)
            end

            def text
              HttpStub::Server::Stub::Response::TextBody.new(args_with_body)
            end

          end

        end

      end
    end
  end
end
