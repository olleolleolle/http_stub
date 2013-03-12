module HttpStub
  module Examples

    class ConfigurerWithInitializationObserver
      include HttpStub::Configurer

      host "localhost"
      port 8001

      def after_initialize
        stub!("/an_initialization_stub", method: :get, response: { status: 201, body: "Initialization stub body" })
      end

    end

  end
end
