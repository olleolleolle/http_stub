module HttpStub
  module Examples

    class ConfigurerWithTrivialStub
      include HttpStub::Configurer

      stub_server.add_stub! do
        match_requests("/a_class_stub", method: :get).respond_with(status: 201, body: "Class stub body")
      end
    end

  end
end
