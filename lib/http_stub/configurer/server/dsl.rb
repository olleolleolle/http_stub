module HttpStub
  module Configurer
    module Server

      class DSL

        def initialize(server_facade)
          @server_facade = server_facade
        end

        def has_started!
          @server_facade.remember_state
        end

        def build_stub(&block)
          builder = HttpStub::Configurer::Request::StubPayloadBuilder.new
          block.call(builder) if block_given?
          builder
        end

        def add_stub!(builder=nil, &block)
          resolved_builder = builder || self.build_stub(&block)
          @server_facade.stub_response(HttpStub::Configurer::Request::Stub.new(resolved_builder.build))
        end

        def add_activator!(&block)
          builder = HttpStub::Configurer::Request::StubActivatorPayloadBuilder.new
          block.call(builder)
          @server_facade.stub_activator(HttpStub::Configurer::Request::StubActivator.new(builder.build))
        end

        def activate!(uri)
          @server_facade.activate(uri)
        end

        def reset!
          @server_facade.recall_state
        end

        def clear_stubs!
          @server_facade.clear_stubs
        end

        def clear_activators!
          @server_facade.clear_activators
        end

      end

    end
  end
end
