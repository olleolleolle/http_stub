module HttpStub
  module Server
    module Stub

      class Controller

        def initialize(stub_registry, match_result_registry)
          @stub_registry         = stub_registry
          @match_result_registry = match_result_registry
        end

        def register(request, logger)
          stub = HttpStub::Server::Stub.create(HttpStub::Server::Stub::Parser.parse(request))
          @stub_registry.add(stub, logger)
          HttpStub::Server::Response.success("location" => stub.stub_uri)
        end

        def match(request, logger)
          stub = @stub_registry.match(request, logger)
          response = stub ? stub.response_for(request) : HttpStub::Server::Response::NOT_FOUND
          @match_result_registry.add(HttpStub::Server::Stub::Match::Result.new(request, response, stub), logger)
          response
        end

        def clear(logger)
          [ @stub_registry, @match_result_registry ].each { |registry| registry.clear(logger) }
        end

      end

    end
  end
end
