module HttpStub
  module Models

    class Response

      SUCCESS = HttpStub::Models::StubResponse::Text.new("status" => 200, "body" => "OK").freeze
      ERROR   = HttpStub::Models::StubResponse::Text.new("status" => 404, "body" => "ERROR").freeze
      EMPTY   = HttpStub::Models::StubResponse::Text.new.freeze

    end

  end
end
