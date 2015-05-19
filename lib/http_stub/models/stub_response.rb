module HttpStub
  module Models

    module StubResponse

      def self.create(args)
        args["body"].is_a?(Hash) ?
          HttpStub::Models::StubResponse::File.new(args) : HttpStub::Models::StubResponse::Text.new(args)
      end

    end

  end
end
