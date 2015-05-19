module HttpStub
  module Configurer
    module Server

      class DSL

        def initialize(server_facade)
          @server_facade     = server_facade
          @response_defaults = {}
        end

        def response_defaults=(args)
          @response_defaults = args
        end

        def has_started!
          @server_facade.server_has_started
        end

        def build_stub(&block)
          builder = HttpStub::Configurer::Request::StubBuilder.new(@response_defaults)
          block.call(builder) if block_given?
          builder
        end

        def add_stub!(builder=nil, &block)
          resolved_builder = builder || self.build_stub(&block)
          @server_facade.stub_response(resolved_builder.build)
        end

        def add_stubs!(builders)
          builders.each { |builder| add_stub!(builder) }
        end

        def add_activator!(&block)
          builder = HttpStub::Configurer::Request::StubActivatorBuilder.new(@response_defaults)
          block.call(builder)
          @server_facade.stub_activator(builder.build)
        end

        def activate!(uri)
          @server_facade.activate(uri)
        end

        def remember_stubs
          @server_facade.remember_stubs
        end

        def recall_stubs!
          @server_facade.recall_stubs
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
