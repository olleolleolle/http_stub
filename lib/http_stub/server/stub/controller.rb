module HttpStub
  module Server
    module Stub

      class Controller

        def register(request, logger)
          stub = HttpStub::Server::Stub.create(HttpStub::Server::Stub::Parser.parse(request))
          request.session.add_stub(stub, logger)
          HttpStub::Server::Response.ok("headers" => { "location" => stub.uri })
        end

        def match(request, logger)
          stub = request.session.match(request, logger)
          response = stub ? stub.response_for(request) : HttpStub::Server::Response::NOT_FOUND
          request.session.add_match(HttpStub::Server::Stub::Match::Match.new(request, response, stub), logger) if stub
          request.session.add_miss(HttpStub::Server::Stub::Match::Miss.new(request), logger) unless stub
          response
        end

        def find(request, logger)
          request.session.find_stub(request.parameters[:id], logger)
        end

        def find_all(request)
          request.session.stubs
        end

        def remember_state(request)
          request.session.remember
        end

        def recall_state(request)
          request.session.recall
        end

        def clear(request, logger)
          request.session.clear(logger)
        end

      end

    end
  end
end
