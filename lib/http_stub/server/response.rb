module HttpStub
  module Server

    class Response

      class << self

        def ok(opts={})
          HttpStub::Server::Stub::Response.create({ body: "OK" }.merge(opts).merge(status: 200))
        end

        def invalid_request(cause)
          HttpStub::Server::Stub::Response.create(status: 400, body: cause.to_s)
        end

      end

      OK        = ok.freeze
      NOT_FOUND = HttpStub::Server::Stub::Response.create(status: 404, body: "NOT FOUND").freeze
      EMPTY     = HttpStub::Server::Stub::Response.create.freeze

    end

  end
end
