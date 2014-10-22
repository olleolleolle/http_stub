module HttpStub
  module Examples

    class ConfigurerWithTriggers
      include HttpStub::Configurer

      triggered_stubs = (1..3).map do |trigger_number|
        stub_server.build_stub do |stub|
          stub.match_requests("/triggered_stub_#{trigger_number}", method: :get)
          stub.respond_with(body: "Triggered stub body #{trigger_number}")
        end
      end

      stub_server.add_stub! do |stub|
        stub.match_requests("/a_stub", method: :get)
        stub.respond_with(body: "Stub activator body")
        stub.and_add_stubs(triggered_stubs)
      end
    end

  end
end
