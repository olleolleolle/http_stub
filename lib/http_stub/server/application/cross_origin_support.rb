module HttpStub
  module Server
    module Application

      module CrossOriginSupport

        module Helpers

          def add_headers_if_necessary
            response.headers.merge!(
              "Access-Control-Allow-Origin"  => "*",
              "Access-Control-Allow-Methods" => @http_stub_request.method.upcase,
              "Access-Control-Allow-Headers" => @http_stub_request.headers.keys.join(",")
            ) if settings.cross_origin_support?
          end

          def handle_options_if_necessary
            pass unless settings.cross_origin_support?
            halt 200
          end

        end

        def self.registered(application)
          application.helpers HttpStub::Server::Application::CrossOriginSupport::Helpers
          application.before { add_headers_if_necessary }
          application.options("*") { handle_options_if_necessary }
        end

      end

    end
  end
end
