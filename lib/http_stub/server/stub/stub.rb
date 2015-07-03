module HttpStub
  module Server
    module Stub

      class Stub

        attr_reader :uri, :method, :headers, :parameters, :body, :response, :triggers, :stub_uri

        def initialize(args)
          @id          = args["id"] || SecureRandom.uuid
          @uri         = HttpStub::Server::Stub::Match::Rule::Uri.new(args["uri"])
          @method      = HttpStub::Server::Stub::Match::Rule::Method.new(args["method"])
          @headers     = HttpStub::Server::Stub::Match::Rule::Headers.new(args["headers"])
          @parameters  = HttpStub::Server::Stub::Match::Rule::Parameters.new(args["parameters"])
          @body        = HttpStub::Server::Stub::Match::Rule::Body.create(args["body"])
          @response    = HttpStub::Server::Stub::Response.create(args["response"])
          @triggers    = HttpStub::Server::Stub::Triggers.new(args["triggers"])
          @stub_uri    = "/stubs/#{@id}"
          @description = args.to_s
        end

        def matches?(criteria, logger)
          criteria.is_a?(String) ? matches_by_id?(criteria) : matches_by_rules?(criteria, logger)
        end

        def to_s
          @description
        end

        private

        def matches_by_id?(criteria)
          criteria == @id
        end

        def matches_by_rules?(request, logger)
          [ @uri, @method, @headers, @parameters, @body ].all? { |matcher| matcher.matches?(request, logger) }
        end

      end

    end
  end
end
