module HttpStub
  module Configurer
    module DSL

      class SessionEndpointTemplate

        delegate :match_requests, :schema, :respond_with, :trigger, :invoke, :build_stub, to: :@stub_builder_template

        def initialize(session, default_stub_template, &block)
          @session               = session
          @stub_builder_template = HttpStub::Configurer::DSL::StubBuilderTemplate.new(default_stub_template, &block)
        end

        def add_stub!(response_overrides={}, &block)
          @session.add_stub!(self.build_stub(response_overrides, &block))
        end

      end

    end
  end
end
