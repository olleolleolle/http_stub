module HttpStub
  module Examples

    class ConfigurerWithInitializeCallback
      include HttpStub::Configurer

      def self.on_initialize
        stub_server.add_stub! do
          match_requests(uri: "/stubbed_on_initialize_path", method: :get)
          respond_with(status: 200, body: "Stubbed on initialize body")
        end
      end

    end

  end
end
