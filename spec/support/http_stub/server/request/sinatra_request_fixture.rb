module HttpStub
  module Server
    module Request

      class SinatraRequestFixture

        def self.create(args={})
          rack_request = Rack::RequestFixture.create(args)
          HttpStub::Server::Request::SinatraRequest.new(rack_request, rack_request.params)
        end

      end

    end
  end
end
