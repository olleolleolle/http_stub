module HttpStub
  module Configurer
    module Server

      class SessionFacade

        REQUEST_FACTORY = HttpStub::Configurer::Request::Http::Factory

        private_constant :REQUEST_FACTORY

        def initialize(session_id, request_processor)
          @session_id          = session_id
          @request_processor   = request_processor
          @session_description = "session '#{session_id}'"
        end

        def mark_as_default
          @request_processor.submit(
            request:     REQUEST_FACTORY.post("sessions/default", http_stub_session_id: @session_id),
            description: "marking #{@session_description} as the default"
          )
        end

        def stub_response(stub)
          @request_processor.submit(
            request:     REQUEST_FACTORY.multipart("stubs", stub, http_stub_session_id: @session_id),
            description: "stubbing '#{stub}' in #{@session_description}"
          )
        end

        def activate(scenario_names)
          parameters = { http_stub_session_id: @session_id, "names[]" => scenario_names }
          @request_processor.submit(
            request:     REQUEST_FACTORY.post("scenarios/activate", parameters),
            description: "activating #{scenario_names.map { |name| "'#{name}'" }.join(", ")} in #{@session_description}"
          )
        end

        def reset_stubs
          @request_processor.submit(
            request:     REQUEST_FACTORY.post("stubs/reset", http_stub_session_id: @session_id),
            description: "resetting stubs in #{@session_description}"
          )
        end

        def clear_stubs
          @request_processor.submit(
            request:     REQUEST_FACTORY.delete("stubs", http_stub_session_id: @session_id),
            description: "clearing stubs in #{@session_description}"
          )
        end

        def delete
          @request_processor.submit(
            request:     REQUEST_FACTORY.delete("sessions", http_stub_session_id: @session_id),
            description: "deleting #{@session_description}"
          )
        end

      end

    end
  end
end
