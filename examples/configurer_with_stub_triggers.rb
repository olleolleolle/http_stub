module HttpStub
  module Examples

    class ConfigurerWithStubTriggers
      include HttpStub::Configurer

      triggered_stubs = (1..3).map do |trigger_number|
        stub_server.build_stub do
          match_requests("/triggered_stub_#{trigger_number}", method: :get)
          respond_with(body: "Triggered stub body #{trigger_number}")
        end
      end

      stub_server.add_stub! do
        match_requests("/a_stub", method: :get).respond_with(body: "Stub activator body").trigger(triggered_stubs)
      end

    end

  end
end
