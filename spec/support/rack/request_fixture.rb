module Rack

  class RequestFixture

    def self.create
      Rack::Request.new("PATH_INFO"      => "/some/path/info",
                        "REQUEST_METHOD" => "GET",
                        "rack.input"     => StringIO.new)
    end

  end

end
