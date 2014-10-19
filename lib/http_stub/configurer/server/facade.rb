module HttpStub
  module Configurer
    module Server

      class Facade

        def initialize(configurer)
          @state_manager = HttpStub::Configurer::Server::StateManager.new(configurer)
        end

        def stub_response(request)
          @state_manager.add(request: request, description: "stubbing '#{request.stub_uri}'", resetable: true)
        end

        def stub_activator(request)
          @state_manager.add(request: request, description: "registering activator '#{request.activation_uri}'")
        end

        def activate(uri)
          @state_manager.add(request: Net::HTTP::Get.new(uri), description: "activating '#{uri}'", resetable: true)
        end

        def flush_pending_state
          @state_manager.flush_pending_state
        end

        def remember_state
          @state_manager.remember
        end

        def recall_state
          clear_stubs
          @state_manager.recall
        end

        def clear_stubs
          @state_manager.add(request: Net::HTTP::Delete.new("/stubs"), description: "clearing stubs")
        end

        def clear_activators
          @state_manager.add(request: Net::HTTP::Delete.new("/stubs/activators"), description: "clearing activators")
        end

      end

    end
  end
end
