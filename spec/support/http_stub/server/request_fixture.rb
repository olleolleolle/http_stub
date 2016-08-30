module HttpStub
  module Server

    class RequestFixture

      class << self

        def create(rack_request=Rack::RequestFixture.create)
          request_factory.create(rack_request, rack_request.params, HttpServerManager::Test::SilentLogger)
        end

        private

        def request_factory
          @request_factory ||= HttpStub::Server::Request::Factory.new(
            nil, HttpStub::Server::Registry.new("session"), HttpStub::Server::Registry.new("scenario")
          )
        end

      end

    end

  end
end
