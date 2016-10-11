module HttpStub
  module Server

    class RequestFixture

      class << self

        def create(rack_request=Rack::RequestFixture.create)
          request_factory.create(rack_request, rack_request.params, HttpServerManager::Test::SilentLogger)
        end

        private

        def request_factory
          @session_configuration ||= HttpStub::Server::Session::Configuration.new(nil)
          @request_factory       ||= HttpStub::Server::Request::Factory.new(
            @session_configuration, HttpStub::Server::MemoryFixture.create(@session_configuration)
          )
        end

      end

    end

  end
end
