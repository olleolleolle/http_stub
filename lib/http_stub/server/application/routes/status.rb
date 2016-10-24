module HttpStub
  module Server
    module Application
      module Routes

        module Status

          def initialize
            super()
            @status_controller = HttpStub::Server::Status::Controller.new(@session_configuration, @server_memory)
          end

          def self.included(application)
            application.instance_eval do

              namespace "/http_stub/status" do

                get do
                  halt 200, @status_controller.current
                end

                post "/initialized" do
                  @status_controller.initialized
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
