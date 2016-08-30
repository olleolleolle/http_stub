module HttpStub
  module Server
    module Application
      module Routes

        module Session

          NAMESPACE           = "/http_stub/sessions".freeze
          DEFAULT_SESSION_URI = "#{NAMESPACE}/#{HttpStub::Server::Session::DEFAULT_ID}".freeze

          private_constant :NAMESPACE, :DEFAULT_SESSION_URI

          def initialize
            super()
            @session_controller = HttpStub::Server::Session::Controller.new(@session_registry)
          end

          def self.included(application)
            application.instance_eval do

              get "/http_stub" do
                redirect settings.session_identifier? ? NAMESPACE : DEFAULT_SESSION_URI
              end

              namespace NAMESPACE do

                get do
                  haml :sessions, {}, sessions: @session_controller.find_all
                end

                get "/:id" do
                  establish_request
                  haml :session, {}, session: @session_controller.find(@http_stub_request, logger)
                end

              end

            end
          end

        end

      end
    end
  end
end
