module HttpStub
  module Server
    module Request

      class Parameters < ::HashWithIndifferentAccess
        include HttpStub::Extensions::Core::Hash::Formatted

        class << self
          alias_method :create, :new
        end

        def initialize(parameter_hash={})
          super(parameter_hash, "=", "&")
        end

      end

    end

  end
end
