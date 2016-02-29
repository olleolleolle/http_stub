module HttpStub
  module Server

    class Application < Sinatra::Base

      set :root, File.dirname(__FILE__)

      register Sinatra::Partial

      enable :dump_errors, :logging, :partial_underscores

      def initialize
        super()
        @match_registry      = HttpStub::Server::Registry.new("match")
        @stub_registry       = HttpStub::Server::Stub::Registry.new(@match_registry)
        @scenario_registry   = HttpStub::Server::Registry.new("scenario")
        @stub_controller     = HttpStub::Server::Stub::Controller.new(@stub_registry)
        @scenario_controller = HttpStub::Server::Scenario::Controller.new(@scenario_registry, @stub_registry)
      end

      private

      SUPPORTED_REQUEST_TYPES = [ :get, :post, :put, :delete, :patch, :options ].freeze

      def self.any_request_type(path, opts={}, &block)
        SUPPORTED_REQUEST_TYPES.each { |type| self.send(type, path, opts, &block) }
      end

      before do
        @response_pipeline = HttpStub::Server::ResponsePipeline.new(self)
        @http_stub_request = HttpStub::Server::Request.new(request)
      end

      public

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
        haml :matches, {}, matches: @match_registry.all
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

      any_request_type(//) do
        response = @stub_controller.replay(@http_stub_request, logger)
        @response_pipeline.process(response)
      end

      helpers do

        def h(text)
          Rack::Utils.escape_html(text)
        end

      end

    end

  end
end
