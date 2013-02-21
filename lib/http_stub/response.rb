module HttpStub

  class Response < ImmutableStruct.new(:status, :body)
    SUCCESS = HttpStub::Response.new(status: 200, body: "")
    ERROR = HttpStub::Response.new(status: 404, body: "")
    EMPTY = HttpStub::Response.new()

    def empty?
      self == HttpStub::Response::EMPTY
    end

  end

end
