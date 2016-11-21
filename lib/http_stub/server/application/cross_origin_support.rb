module HttpStub
  module Server
    module Application

      module CrossOriginSupport

        module Helpers

          def add_headers_if_necessary
            if settings.cross_origin_support?
              response.headers.merge!(
                "Access-Control-Allow-Origin"  => "*",
                "Access-Control-Allow-Methods" => determine_allowed_methods,
                "Access-Control-Allow-Headers" => determine_allowed_headers
              )
            end
          end

          def handle_options_if_necessary
            pass unless settings.cross_origin_support?
            halt 200
          end

          private

          def determine_allowed_methods
            http_stub_request.headers["Access_Control_Request_Method"] || http_stub_request.method.upcase
          end

          def determine_allowed_headers
            http_stub_request.headers["Access_Control_Request_Headers"] || http_stub_request.headers.keys.join(",")
          end

        end

        def self.registered(application)
          application.instance_eval do
            helpers HttpStub::Server::Application::CrossOriginSupport::Helpers
            before { add_headers_if_necessary }
            options("*") { handle_options_if_necessary }
          end
        end

      end

    end
  end
end
