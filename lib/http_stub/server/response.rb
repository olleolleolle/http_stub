module HttpStub
  module Server

    class Response

      def self.ok(opts={})
        HttpStub::Server::Stub::Response::Text.new(
          { "headers" => {}, "body" => "OK" }.merge(opts).merge("status" => 200)
        )
      end

      OK        = ok.freeze
      NOT_FOUND = HttpStub::Server::Stub::Response::Text.new("status" => 404, "body" => "NOT FOUND").freeze
      EMPTY     = HttpStub::Server::Stub::Response::Text.new.freeze

    end

  end
end
