module HttpStub
  module Server

    class RequestFixture

      class << self

        def create(args={})
          rack_request = args[:rack_request] || create_rack_request(args)
          request_factory.create(rack_request, rack_request.params, HttpStub::Server::SilentLogger)
        end

        private

        def create_rack_request(args)
          rack_request_args = args.merge({}).tap { |rack_request_args| rack_request_args.delete(:session_id) }
          rack_request_args.deep_merge!(headers: { session_id: args[:session_id] }) if args[:session_id]
          Rack::RequestFixture.create(rack_request_args)
        end

        def request_factory
          @server_memory   ||= HttpStub::Server::Memory::Memory.new(HttpStub::Configurator::State.new)
          @request_factory ||= HttpStub::Server::Request::Factory.new({ header: :session_id }, @server_memory)
        end

      end

    end

  end
end
