module HttpStub
  module Server
    module Request

      class Parameters < ::HashWithIndifferentAccess
        include HttpStub::Extensions::Core::Hash::Formatted

        def self.create(rack_request)
          self.new(rack_request.params)
        end

        def initialize(parameter_hash={})
          super(parameter_hash, "=", "&")
        end

      end

    end

  end
end
