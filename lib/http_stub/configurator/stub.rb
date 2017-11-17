module HttpStub
  module Configurator

    module Stub

      def self.create(parent=nil, &block)
        HttpStub::Configurator::Stub::Stub.new(parent, &block)
      end

    end

  end
end
