module Http
  module Stub

    class Server < ::Sinatra::Base

      enable :dump_errors, :logging

      def initialize
        super()
        @registry = Http::Stub::Registry.new
      end

      private

      SUPPORTED_REQUEST_TYPES = [:get, :post, :put, :delete, :patch, :options].freeze

      def self.any_request_type(path, opts={}, &block)
        SUPPORTED_REQUEST_TYPES.each { |type| self.send(type, path, opts, &block) }
      end

      public

      # Sample request body:
      # {
      #   "uri": "/some/path",
      #   "method": "get",
      #   "parameters": {
      #     "key": "value",
      #     ...
      #   },
      #   "response": {
      #     "status": "200",
      #     "body": "Hello World"
      #   }
      # }
      post "/stub" do
        @registry.add(Http::Stub::Stub.new(request), request)
        halt 200
      end

      delete "/stubs" do
        @registry.clear(request)
        halt 200
      end

      any_request_type(//) { handle_stub_request }

      private

      def handle_stub_request
        stub = @registry.find_for(request)
        stub ? halt(stub.response.status, stub.response.body) : halt(404)
      end

    end

  end
end
