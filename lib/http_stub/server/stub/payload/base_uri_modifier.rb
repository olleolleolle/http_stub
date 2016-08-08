module HttpStub
  module Server
    module Stub
      module Payload

        class BaseUriModifier

          def self.modify!(payload, request)
            payload["base_uri"] = request.base_uri
          end

        end

      end
    end
  end
end
