module HttpStub
  module Server
    module Application
      module Routes

        module Memory

          def initialize
            super()
            @memory_controller = HttpStub::Server::Memory::Controller.new(@session_configuration, @server_memory)
          end

          def self.included(application)
            application.instance_eval do

              namespace "/http_stub/memory" do

                get do
                  haml :stubs, {}, stubs: @memory_controller.find_stubs
                end

                delete do
                  @memory_controller.reset(logger)
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
