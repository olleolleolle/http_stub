module HttpStub
  module Extensions
    module Core
      module Hash

        class WithIndifferentAndInsensitiveAccess < ::Hash
          include HttpStub::Extensions::Core::Hash::IndifferentAndInsensitiveAccess

          def initialize(hash={})
            self.merge!(hash || {})
          end

        end

      end
    end
  end
end
