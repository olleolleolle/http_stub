module HttpStub
  module Examples

    class ConfiguratorWithCrossOriginSupport
      include HttpStub::Configurator

      stub_server.enable :cross_origin_support

      stub_server.add_scenario_with_one_stub!("Get scenario") do
        match_requests(uri: "/some_path", method: :get).respond_with(status: 204)
      end

      stub_server.add_scenario_with_one_stub!("Options scenario") do
        match_requests(uri: "/some_path", method: :options).respond_with(status: 302)
      end

    end

  end
end
