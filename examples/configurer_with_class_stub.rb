module HttpStub
  module Examples

    class ConfigurerWithClassStub
      include HttpStub::Configurer

      stub! "/a_class_stub", method: :get, response: { status: 201, body: "Class stub body" }
    end

  end
end
