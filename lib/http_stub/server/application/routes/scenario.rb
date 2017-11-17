module HttpStub
  module Server
    module Application
      module Routes

        module Scenario

          def initialize
            super()
            @scenario_controller = HttpStub::Server::Scenario::Controller.new(@server_memory)
          end

          def self.included(application)
            application.instance_eval do

              namespace "/http_stub/scenarios" do

                get do
                  pass unless http_stub_request.parameters[:name]
                  haml :scenario, {}, scenario: @scenario_controller.find(http_stub_request, logger)
                end

                get do
                  haml :scenarios, {}, scenarios: @scenario_controller.find_all
                end

                post "/activate" do
                  response = @scenario_controller.activate(http_stub_request, logger)
                  response.serve_on(self)
                end

              end

            end
          end

        end

      end
    end
  end
end
