module HttpStub
  module Server
    module Application
      module Routes

        module Stub

          def initialize
            super()
            @stub_controller       = HttpStub::Server::Stub::Controller.new
            @stub_match_controller = HttpStub::Server::Stub::Match::Controller.new
          end

          def self.included(application)
            application.instance_eval do

              namespace "/http_stub/stubs" do

                post do
                  response = @stub_controller.register(@http_stub_request, logger)
                  @response_pipeline.process(response)
                end

                delete do
                  @stub_controller.clear(@http_stub_request, logger)
                  halt 200, "OK"
                end

                namespace "/memory" do

                  post do
                    @stub_controller.remember_state(@http_stub_request)
                    halt 200, "OK"
                  end

                  get do
                    @stub_controller.recall_state(@http_stub_request)
                    halt 200, "OK"
                  end

                end

                namespace "/matches" do

                  get do
                    haml :stub_matches, {}, matches: @stub_match_controller.matches(@http_stub_request)
                  end

                  get "/last" do
                    response = @stub_match_controller.last_match(@http_stub_request, logger)
                    @response_pipeline.process(response)
                  end

                end

                get "/misses" do
                  haml :stub_misses, {}, misses: @stub_match_controller.misses(@http_stub_request)
                end

                get do
                  haml :stubs, {}, stubs: @stub_controller.find_all(@http_stub_request)
                end

                get "/:id" do
                  establish_request
                  haml :stub, {}, the_stub: @stub_controller.find(@http_stub_request, logger)
                end

              end

              any_request_method "*" do
                response = @stub_controller.match(@http_stub_request, logger)
                @response_pipeline.process(response)
              end

            end
          end

        end

      end
    end
  end
end
