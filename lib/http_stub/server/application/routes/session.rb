module HttpStub
  module Server
    module Application
      module Routes

        module Session

          def initialize
            super()
            @session_controller = HttpStub::Server::Session::Controller.new(@server_memory)
          end

          def self.included(application)
            application.instance_eval do

              namespace "/http_stub" do

                get do
                  redirect settings.session_identifier? ? "/http_stub/sessions" : "/http_stub/sessions/transactional"
                end

                namespace "/sessions" do

                  get "/transactional" do
                    haml :transactional_session, {}, session: @session_controller.find_transactional(logger)
                  end

                  get do
                    pass unless http_stub_request.session_id
                    haml :session, {}, session: @session_controller.find(http_stub_request, logger)
                  end

                  get do
                    haml :sessions, {}, sessions: @session_controller.find_all
                  end

                  delete do
                    pass unless http_stub_request.session_id
                    @session_controller.delete(http_stub_request, logger)
                    halt 200, "OK"
                  end

                  delete do
                    @session_controller.clear(logger)
                    halt 200, "OK"
                  end

                end

              end

            end
          end

        end

      end
    end
  end
end
