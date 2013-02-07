require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)
require "json"

module Http
  module Stub

    class Server < ::Sinatra::Base

      SUPPORTED_REQUEST_TYPES = [:get, :post, :put, :delete, :patch, :options].freeze

      enable :dump_errors, :logging

      def initialize()
        super()
        @response_register = {}
      end

      private

      def self.any_request_type(path, opts={}, &block)
        SUPPORTED_REQUEST_TYPES.each { |type| self.send(type, path, opts, &block) }
      end

      public

      # Sample request body:
      # {
      #   "uri": "/some/path",
      #   "method": "get",
      #   "response": {
      #     "status": "200",
      #     "body": "Hello World"
      #   }
      # }
      post "/stub" do
        data = JSON.parse(request.body.read)
        logger.info "Stub registered: #{data}"
        @response_register[data["uri"]] = data
        halt 200
      end

      any_request_type(//) { handle_stub_request }

      private

      def handle_stub_request
        logger.info "Stub response requested: #{request}"
        stub_data = @response_register[request.path_info]
        if stub_data && stub_data["method"].downcase == request.request_method.downcase
          response_data = stub_data["response"]
          halt response_data["status"] unless response_data["status"] == "200"
          response_data["body"]
        else
          halt 404
        end
      end

    end

  end
end
