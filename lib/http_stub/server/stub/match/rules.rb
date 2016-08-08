module HttpStub
  module Server
    module Stub
      module Match

        class Rules

          attr_reader :uri, :method, :headers, :parameters, :body

          def initialize(args)
            @uri        = HttpStub::Server::Stub::Match::Rule::Uri.new(args["uri"])
            @method     = HttpStub::Server::Stub::Match::Rule::Method.new(args["method"])
            @headers    = HttpStub::Server::Stub::Match::Rule::Headers.new(args["headers"])
            @parameters = HttpStub::Server::Stub::Match::Rule::Parameters.new(args["parameters"])
            @body       = HttpStub::Server::Stub::Match::Rule::Body.create(args["body"])
          end

          EMPTY = self.new("uri" => "", "method" => "", "headers" => {}, "parameters" => {}, "body" => "").freeze

          def matches?(request, logger)
            [ @uri, @method, @headers, @parameters, @body ].all? { |matcher| matcher.matches?(request, logger) }
          end

          def to_hash
            { uri: @uri, method: @method, headers: @headers, parameters: @parameters, body: @body }
          end

        end

      end
    end
  end
end
