module HttpStub
  module Configurer
    module Server

      class Facade

        attr_reader :default_session

        def initialize(configuration)
          @request_processor = HttpStub::Configurer::Server::RequestProcessor.new(configuration)
        end

        def server_has_started
          @request_processor.disable_buffering!
        end

        def flush_requests
          @request_processor.flush!
        end

        def reset
          @request_processor.submit(
            request:     HttpStub::Configurer::Request::Http::Factory.delete("memory"),
            description: "resetting server"
          )
        end

        def define_scenario(scenario)
          @request_processor.submit(
            request:     HttpStub::Configurer::Request::Http::Factory.multipart("scenarios", scenario),
            description: "registering scenario '#{scenario}'"
          )
        end

        def clear_scenarios
          @request_processor.submit(
            request:     HttpStub::Configurer::Request::Http::Factory.delete("scenarios"),
            description: "clearing scenarios"
          )
        end

        def create_session_facade(id)
          HttpStub::Configurer::Server::SessionFacade.new(id, @request_processor)
        end

        def clear_sessions
          @request_processor.submit(
            request:     HttpStub::Configurer::Request::Http::Factory.delete("sessions"),
            description: "clearing sessions"
          )
        end

      end

    end
  end
end
