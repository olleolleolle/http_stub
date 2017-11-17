module HttpStub
  module Configurator
    module Stub

      class Template

        attr_reader :template

        delegate :match_requests, :schema, :respond_with, :trigger, :invoke, to: :@template

        def initialize(parent_template=nil, &block)
          @template = HttpStub::Configurator::Stub.create(parent_template.try(:template), &block)
        end

        def build_stub(response_overrides={}, &block)
          HttpStub::Configurator::Stub.create(@template) do |stub|
            stub.respond_with(response_overrides)
            stub.invoke(&block) if block_given?
          end
        end

      end

    end
  end
end
