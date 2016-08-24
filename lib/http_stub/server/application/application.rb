module HttpStub
  module Server
    module Application

      class Application < Sinatra::Base

        SUPPORTED_REQUEST_TYPES = [ :get, :post, :put, :delete, :patch, :options ].freeze

        private_constant :SUPPORTED_REQUEST_TYPES

        register Sinatra::Partial

        set :root, File.expand_path("../..", __FILE__)
        set :environment, :test
        set :session_identifier, nil

        enable  :dump_errors, :logging, :partial_underscores
        disable :protection, :cross_origin_support

        class << self

          def configure(args)
            configuration = HttpStub::Server::Application::Configuration.new(args)
            configuration.settings.each { |name, value| set(name, value) }
          end

          def any_request_type(path, opts={}, &block)
            SUPPORTED_REQUEST_TYPES.each { |type| self.send(type, path, opts, &block) }
          end

        end

        private_class_method :any_request_type

        def initialize
          super()
          @scenario_registry     = HttpStub::Server::Registry.new("scenario")
          @scenario_controller   = HttpStub::Server::Scenario::Controller.new(@scenario_registry)
          @stub_controller       = HttpStub::Server::Stub::Controller.new
          @stub_match_controller = HttpStub::Server::Stub::Match::Controller.new
          @request_factory = HttpStub::Server::Request::Factory.new(@scenario_registry, settings.session_identifier)
        end

        before do
          @http_stub_request = @request_factory.create(request)
          @response_pipeline = HttpStub::Server::Application::ResponsePipeline.new(self)
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
          haml :stubs, {}, stubs: @stub_controller.find_all(@http_stub_request)
        end

        delete "/http_stub/stubs" do
          @stub_controller.clear(@http_stub_request, logger)
          halt 200, "OK"
        end

        post "/http_stub/stubs/memory" do
          @stub_controller.remember_state(@http_stub_request)
          halt 200, "OK"
        end

        get "/http_stub/stubs/memory" do
          @stub_controller.recall_state(@http_stub_request)
          halt 200, "OK"
        end

        get "/http_stub/stubs/matches" do
          haml :stub_matches, {}, matches: @stub_match_controller.matches(@http_stub_request)
        end

        get "/http_stub/stubs/matches/last" do
          response = @stub_match_controller.last_match(@http_stub_request, logger)
          @response_pipeline.process(response)
        end

        get "/http_stub/stubs/misses" do
          haml :stub_misses, {}, misses: @stub_match_controller.misses(@http_stub_request)
        end

        get "/http_stub/stubs/:id" do
          haml :stub, {}, the_stub: @stub_controller.find(@http_stub_request, logger)
        end

        post "/http_stub/scenarios" do
          response = @scenario_controller.register(@http_stub_request, logger)
          @response_pipeline.process(response)
        end

        get "/http_stub/scenarios" do
          pass unless params[:name]
          haml :scenario, {}, scenario: @scenario_controller.find(@http_stub_request, logger)
        end

        get "/http_stub/scenarios" do
          haml :scenarios, {}, scenarios: @scenario_controller.find_all
        end

        post "/http_stub/scenarios/activate" do
          response = @scenario_controller.activate(@http_stub_request, logger)
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
