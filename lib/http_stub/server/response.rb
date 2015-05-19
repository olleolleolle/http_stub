module HttpStub
  module Server

    class Response

      SUCCESS = HttpStub::Server::StubResponse::Text.new("status" => 200, "body" => "OK").freeze
      ERROR   = HttpStub::Server::StubResponse::Text.new("status" => 404, "body" => "ERROR").freeze
      EMPTY   = HttpStub::Server::StubResponse::Text.new.freeze

    end

  end
end
