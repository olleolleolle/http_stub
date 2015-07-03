module HttpStub
  module Server

    class Response

      def self.success(headers={})
        HttpStub::Server::Stub::Response::Text.new("status" => 200, "headers" => headers, "body" => "OK")
      end

      SUCCESS   = success.freeze
      NOT_FOUND = HttpStub::Server::Stub::Response::Text.new("status" => 404, "body" => "NOT FOUND").freeze
      EMPTY     = HttpStub::Server::Stub::Response::Text.new.freeze

    end

  end
end
