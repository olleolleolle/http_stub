module HttpStub
  module Configurer
    module DSL

      class StubBuilderTemplate

        attr_reader :template

        delegate :match_requests, :schema, :respond_with, :trigger, :invoke, to: :@template

        def initialize(parent_template=nil, &block)
          @template = HttpStub::Configurer::DSL::StubBuilder.new(parent_template.try(:template), &block)
        end

        def build_stub(response_overrides={}, &block)
          HttpStub::Configurer::DSL::StubBuilder.new(@template) do |stub|
            stub.respond_with(response_overrides)
            stub.invoke(&block) if block_given?
          end
        end

      end

    end
  end
end
