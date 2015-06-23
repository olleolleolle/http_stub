module HttpStub
  module Examples

    class ConfigurerWithParts
      include HttpStub::Configurer

      class CallbackPart < HttpStub::Configurer::Part

        def configure_some_stub
          stub_server.add_stub! do |stub|
            stub.match_requests("/registered_in_configure_stub_method", method: :get)
            stub.respond_with(body: "configure stub response")
          end
        end

        def configure_some_stubs
          stub_server.add_stub! do |stub|
            stub.match_requests("/registered_in_configure_stubs_method", method: :get)
            stub.respond_with(body: "configure stubs response")
          end
        end

        def configure_some_scenario
          stub_server.add_one_stub_scenario!("some_scenario") do |stub|
            stub.match_requests("/registered_in_configure_scenario_method", method: :get)
            stub.respond_with(body: "configure scenario response")
          end

          stub_server.activate!("some_scenario")
        end

        def configure_some_scenarios
          stub_server.add_one_stub_scenario!("some_scenarios") do |stub|
            stub.match_requests("/registered_in_configure_scenarios_method", method: :get)
            stub.respond_with(body: "configure scenarios response")
          end

          stub_server.activate!("some_scenarios")
        end

      end

      class AnotherPart < HttpStub::Configurer::Part

        def add_stub
          stub_server.add_stub! do |stub|
            stub.match_requests("/registered_in_another_part", method: :get)
            stub.respond_with(body: "response from another part")
          end
        end

      end

      class APart < HttpStub::Configurer::Part

        def configure_another_stub
          another_part.add_stub
        end

      end

      self.parts = {
        callback_part: CallbackPart.new(self),
        another_part:  AnotherPart.new(self),
        a_part:        APart.new(self)
      }

    end

  end
end
