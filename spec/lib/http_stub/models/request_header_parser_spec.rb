describe HttpStub::Models::RequestHeaderParser do

  let(:non_http_env_elements) do
    {
        "GATEWAY_INTERFACE" => "CGI/1.1",
        "QUERY_STRING" => "some string",
        "REMOTE_ADDR" => "127.0.0.1",
        "SCRIPT_NAME" => "some script",
        "SERVER_NAME" => "localhost",
    }
  end
  let(:env) { non_http_env_elements.merge(request_headers) }
  let(:request) { double("HttpRequest", env: env) }

  describe ".parse" do

    let(:request_headers) { { "HTTP_KEY1" => "value1", "HTTP_KEY2" => "value2", "HTTP_KEY3" => "value3" } }

    it "should return a hash containing request environment entries prefixed with HTTP_" do
      HttpStub::Models::RequestHeaderParser.parse(request).should eql({ "KEY1" => "value1",
                                                                        "KEY2" => "value2",
                                                                        "KEY3" => "value3" })
    end

  end

end
