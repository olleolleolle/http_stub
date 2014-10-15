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
  let(:env) { non_http_env_elements.merge(http_env_elements) }
  let(:request) { double("HttpRequest", env: env) }

  describe ".parse" do
    
    describe "when the request contains request environment entries prefixed with 'HTTP_'" do

      let(:http_env_elements) { { "HTTP_KEY1" => "value1", "HTTP_KEY2" => "value2", "HTTP_KEY3" => "value3" } }

      it "returns a hash containing only those entries with the prefix removed" do
        expect(HttpStub::Models::RequestHeaderParser.parse(request)).to eql({ "KEY1" => "value1",
                                                                          "KEY2" => "value2",
                                                                          "KEY3" => "value3" })
      end

    end
    
    describe "when the request does not contain request environment entries prefixed with 'HTTP_'" do

      let(:http_env_elements) { {} }
      
      it "returns an empty hash" do
        expect(HttpStub::Models::RequestHeaderParser.parse(request)).to eql({})
      end
      
    end

  end

end
