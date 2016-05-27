module HttpStub
  module Server

    class RequestFixture

      class << self

        def create
          HttpStub::Server::Request.create(create_rack_request)
        end

        private

        def create_rack_request
          Rack::Request.new("PATH_INFO"      => "/some/path/info",
                            "REQUEST_METHOD" => "GET",
                            "rack.input"     => StringIO.new)
        end

      end

    end

  end
end
