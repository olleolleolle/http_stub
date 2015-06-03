module HttpStub
  module Server

    class Response

      SUCCESS = HttpStub::Server::Stub::Response::Text.new("status" => 200, "body" => "OK").freeze
      ERROR   = HttpStub::Server::Stub::Response::Text.new("status" => 404, "body" => "ERROR").freeze
      EMPTY   = HttpStub::Server::Stub::Response::Text.new.freeze

    end

  end
end
