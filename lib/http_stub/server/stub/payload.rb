module HttpStub
  module Server
    module Stub

      module Payload

        MODIFIERS = [ HttpStub::Server::Stub::Payload::BaseUriModifier,
                      HttpStub::Server::Stub::Payload::ResponseBodyModifier ].freeze

        private_constant :MODIFIERS

        def self.modify!(payload, request)
          payload.tap { MODIFIERS.each { |modifier| modifier.modify!(payload, request) } }
        end

      end

    end
  end
end
