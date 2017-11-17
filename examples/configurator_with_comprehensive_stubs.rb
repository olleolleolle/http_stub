module HttpStub
  module Examples

    class ConfiguratorWithComprehensiveStubs
      include HttpStub::Configurator

      def self.stub_builder
        HttpStub::Examples::StubBuilder.new(stub_server)
      end

      stub_server.add_stub!(stub_builder.build)

      stub_server.add_stub!(stub_builder.with_request_parameters!.build)

      stub_server.add_stub!(stub_builder.with_request_body!.build)

      stub_server.add_stub!(stub_builder.with_request_parameters!.and.with_request_interpolation!.build)

    end

  end
end
