module HttpStub
  module Server

    module Request

      def self.create(rack_request)
        HttpStub::Server::Request::Request.new(rack_request)
      end

    end
  end
end
