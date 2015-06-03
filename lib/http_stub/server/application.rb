module HttpStub
  module Server

    class Application < Sinatra::Base

      register Sinatra::Partial

      enable :dump_errors, :logging, :partial_underscores

      def initialize
        super()
        @stub_registry       = HttpStub::Server::Stub::Registry.new
        @scenario_registry   = HttpStub::Server::Registry.new("scenario")
        @stub_controller     = HttpStub::Server::Stub::Controller.new(@stub_registry)
        @scenario_controller = HttpStub::Server::Scenario::Controller.new(@scenario_registry, @stub_registry)
      end

      private

      SUPPORTED_REQUEST_TYPES = [ :get, :post, :put, :delete, :patch, :options ].freeze

      def self.any_request_type(path, opts={}, &block)
        SUPPORTED_REQUEST_TYPES.each { |type| self.send(type, path, opts, &block) }
      end

      before { @response_pipeline = HttpStub::Server::ResponsePipeline.new(self) }

      public

      # Sample request body:
      # {
      #   "uri": "/some/path",
      #   "method": "get",
      #   "headers": {
      #     "key": "value",
      #     ...
      #   },
      #   "parameters": {
      #     "key": "value",
      #     ...
      #   },
      #   "response": {
      #     "status": "200",
      #     "body": "Hello World"
      #   }
      # }
      post "/stubs" do
        response = @stub_controller.register(request)
        @response_pipeline.process(response)
      end

      get "/stubs" do
        haml :stubs, {}, stubs: @stub_registry.all
      end

      delete "/stubs" do
        @stub_controller.clear(request)
        halt 200, "OK"
      end

      post "/stubs/memory" do
        @stub_registry.remember
        halt 200, "OK"
      end

      get "/stubs/memory" do
        @stub_registry.recall
        halt 200, "OK"
      end

      # Sample request body:
      # {
      #   "activation_uri": "/some/path",
      #   "stubs": [
      #     {
      #       ... see /stub ...
      #     },
      #     ...
      #   ]
      # }
      post "/stubs/scenarios" do
        response = @scenario_controller.register(request)
        @response_pipeline.process(response)
      end

      get "/stubs/scenarios" do
        haml :scenarios, {}, scenarios: @scenario_registry.all.sort_by(&:activation_uri)
      end

      delete "/stubs/scenarios" do
        @scenario_controller.clear(request)
        halt 200, "OK"
      end

      get "/application.css" do
        sass :application
      end

      any_request_type(//) { handle_request }

      helpers do

        def h(text)
          Rack::Utils.escape_html(text)
        end

      end

      private

      def handle_request
        response = @stub_controller.replay(request)
        response = @scenario_controller.activate(request) if response.empty?
        response = HttpStub::Server::Response::ERROR if response.empty?
        @response_pipeline.process(response)
      end

    end

  end
end
