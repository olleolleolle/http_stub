module HttpStub
  module Server
    module Stub
      module Response

        class Headers < ::HashWithIndifferentAccess
          include HttpStub::Extensions::Core::Hash::Formatted

          def self.create(hash, body)
            self.new(body.headers.merge(hash || {}))
          end

          private

          def initialize(hash)
            super(hash.stringify_keys, ":")
          end

        end

      end
    end
  end
end
