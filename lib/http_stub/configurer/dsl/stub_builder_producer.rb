module HttpStub
  module Configurer
    module DSL

      module StubBuilderProducer

        def build_stub(&block)
          builder = HttpStub::Configurer::DSL::StubBuilder.new(@response_defaults)
          builder.invoke(&block) if block_given?
          builder
        end

        def add_stubs!(builders)
          builders.each { |builder| add_stub!(builder) }
        end

      end

    end
  end
end
