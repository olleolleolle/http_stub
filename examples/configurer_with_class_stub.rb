module HttpStub
  module Examples

    class ConfigurerWithClassStub
      include HttpStub::Configurer

      host "localhost"
      port 8001

      stub!("/a_class_stub", method: :get, response: { status: 201, body: "Class stub body" })
    end

  end
end
