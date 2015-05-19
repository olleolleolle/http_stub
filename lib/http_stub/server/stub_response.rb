module HttpStub
  module Server

    module StubResponse

      def self.create(args)
        args["body"].is_a?(Hash) ?
          HttpStub::Server::StubResponse::File.new(args) : HttpStub::Server::StubResponse::Text.new(args)
      end

    end

  end
end
