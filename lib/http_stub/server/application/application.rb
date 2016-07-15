module HttpStub
  module Server
    module Application

      class Application < Sinatra::Base

        SUPPORTED_REQUEST_TYPES = [ :get, :post, :put, :delete, :patch, :options ].freeze

        private_constant :SUPPORTED_REQUEST_TYPES

        set :root, File.expand_path("../..", __FILE__)

        register Sinatra::Partial

        enable  :dump_errors, :logging, :partial_underscores
        disable :protection, :cross_origin_support

        def self.any_request_type(path, opts={}, &block)
          SUPPORTED_REQUEST_TYPES.each { |type| self.send(type, path, opts, &block) }
        end

        private_class_method :any_request_type

        def initialize
          super()
          @stub_registry         = HttpStub::Server::Stub::Registry.new
          @scenario_registry     = HttpStub::Server::Registry.new("scenario")
          @match_result_registry = HttpStub::Server::Registry.new("match result")
          @stub_controller       = HttpStub::Server::Stub::Controller.new(@stub_registry, @match_result_registry)
          @scenario_controller   = HttpStub::Server::Scenario::Controller.new(@scenario_registry, @stub_registry)
        end

        before do
          @response_pipeline = HttpStub::Server::Application::ResponsePipeline.new(self)
          @http_stub_request = HttpStub::Server::Request.create(request)
        end

        register HttpStub::Server::Application::CrossOriginSupport

        get "/http_stub" do
          haml :index, {}
        end

        post "/http_stub/stubs" do
          response = @stub_controller.register(@http_stub_request, logger)
          @response_pipeline.process(response)
        end

        get "/http_stub/stubs" do
          haml :stubs, {}, stubs: @stub_registry.all
        end

        delete "/http_stub/stubs" do
          @stub_controller.clear(logger)
          halt 200, "OK"
        end

        post "/http_stub/stubs/memory" do
          @stub_registry.remember
          halt 200, "OK"
        end

        get "/http_stub/stubs/memory" do
          @stub_registry.recall
          halt 200, "OK"
        end

        get "/http_stub/stubs/matches" do
          haml :match_results, {}, match_results: @match_result_registry.all
        end

        get "/http_stub/stubs/:id" do
          haml :stub, {}, the_stub: @stub_registry.find(params[:id], logger)
        end

        post "/http_stub/scenarios" do
          response = @scenario_controller.register(@http_stub_request, logger)
          @response_pipeline.process(response)
        end

        get "/http_stub/scenarios" do
          pass unless params[:name]
          haml :scenario, {}, scenario: @scenario_registry.find(URI.decode_www_form_component(params[:name]), logger)
        end

        get "/http_stub/scenarios" do
          haml :scenarios, {}, scenarios: @scenario_registry.all.sort_by(&:name)
        end

        post "/http_stub/scenarios/activate" do
          response = @scenario_controller.activate(params[:name], logger)
          @response_pipeline.process(response)
        end

        delete "/http_stub/scenarios" do
          @scenario_controller.clear(logger)
          halt 200, "OK"
        end

        get "/application.css" do
          sass :application
        end

        any_request_type "*" do
          response = @stub_controller.match(@http_stub_request, logger)
          @response_pipeline.process(response)
        end

        helpers HttpStub::Server::Application::TextFormattingSupport

      end

    end
  end
end
