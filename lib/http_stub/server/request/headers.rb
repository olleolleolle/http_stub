module HttpStub
  module Server
    module Request

      class Headers < ::Hash
        include HttpStub::Extensions::Core::Hash::IndifferentAndInsensitiveAccess
        include HttpStub::Extensions::Core::Hash::Formatted

        def self.create(rack_request)
          rack_request.env.each_with_object(self.new) do |(name, value), result|
            match = name.match(/^(?:HTTP_)?([A-Z0-9_]+)$/)
            result[match[1]] = value if match
          end
        end

        def initialize(header_hash={})
          super(header_hash, ":")
        end

      end

    end

  end
end
