module HttpStub
  module Server
    module Stub

      class Controller

        def initialize(stub_registry, match_registry, miss_registry)
          @stub_registry  = stub_registry
          @match_registry = match_registry
          @miss_registry  = miss_registry
        end

        def register(request, logger)
          stub = HttpStub::Server::Stub.create(HttpStub::Server::Stub::Parser.parse(request))
          @stub_registry.add(stub, logger)
          HttpStub::Server::Response.ok("headers" => { "location" => stub.uri })
        end

        def match(request, logger)
          stub = @stub_registry.match(request, logger)
          response = stub ? stub.response_for(request) : HttpStub::Server::Response::NOT_FOUND
          @match_registry.add(HttpStub::Server::Stub::Match::Match.new(request, response, stub), logger) if stub
          @miss_registry.add(HttpStub::Server::Stub::Match::Miss.new(request), logger) unless stub
          response
        end

        def clear(logger)
          [ @stub_registry, @match_registry, @miss_registry ].each { |registry| registry.clear(logger) }
        end

      end

    end
  end
end
