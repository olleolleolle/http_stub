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

                post do
                  response = @scenario_controller.register(http_stub_request, logger)
                  @response_pipeline.process(response)
                end

                get do
                  pass unless http_stub_request.parameters[:name]
                  haml :scenario, {}, scenario: @scenario_controller.find(http_stub_request, logger)
                end

                get do
                  haml :scenarios, {}, scenarios: @scenario_controller.find_all
                end

                post "/activate" do
                  response = @scenario_controller.activate(http_stub_request, logger)
                  @response_pipeline.process(response)
                end

                delete do
                  @scenario_controller.clear(logger)
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
