module HttpStub
  module Examples

    class ConfigurerWithInitializeCallback
      include HttpStub::Configurer

      def self.on_initialize
        stub! "/stubbed_on_initialize_path", method: :get, response: { status: 200, body: "Stubbed on initialize body" }
      end

    end

  end
end
