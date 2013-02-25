module HttpStub

  class Response

    def initialize(options = {})
      @response_options = options || {}
    end

    SUCCESS = HttpStub::Response.new("status" => 200, "body" => "")
    ERROR = HttpStub::Response.new("status" => 404, "body" => "")
    EMPTY = HttpStub::Response.new()

    def status
      @response_options["status"]
    end

    def body
      @response_options["body"]
    end

    def empty?
      @response_options.empty?
    end

  end

end
