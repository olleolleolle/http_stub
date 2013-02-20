module HttpStub

  class Stub

    Response = ImmutableStruct.new(:status, :body)

    attr_reader :response

    def initialize(request)
      @data = JSON.parse(request.body.read)
      @response = Response.new(status: @data["response"]["status"], body: @data["response"]["body"])
    end

    def stubs?(request)
      @data["uri"] == request.path_info &&
          @data["method"].downcase == request.request_method.downcase &&
          parameters == request.params
    end

    def to_s
      @data.to_s
    end

    private

    def parameters
      @data["parameters"] || {}
    end

  end

end
