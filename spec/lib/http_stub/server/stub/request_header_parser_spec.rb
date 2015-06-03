describe HttpStub::Server::Stub::RequestHeaderParser do

  let(:non_header_env_elements) do
    {
      "rack.version"       => [1, 3],
      "rack.multithreaded" => true,
      "rack.multiprocess"  => false
    }
  end
  let(:env)     { non_header_env_elements.merge(header_env_elements) }
  let(:request) { instance_double(Rack::Request, env: env) }

  describe "::parse" do

    describe "when the request contains environment entries in upper case" do

      let(:header_env_elements) { { "KEY_1" => "value1", "KEY_2" => "value2", "KEY_3" => "value3" } }

      it "returns a hash containing those entries" do
        expect(HttpStub::Server::Stub::RequestHeaderParser.parse(request)).to eql("KEY_1" => "value1",
                                                                            "KEY_2" => "value2",
                                                                            "KEY_3" => "value3")
      end

    end

    describe "when the request contains environment entries in upper case prefixed with 'HTTP_'" do

      let(:header_env_elements) { { "HTTP_KEY_1" => "value1", "HTTP_KEY_2" => "value2", "HTTP_KEY_3" => "value3" } }

      it "returns a hash containing those entries with the prefix removed" do
        expect(HttpStub::Server::Stub::RequestHeaderParser.parse(request)).to include("KEY_1" => "value1",
                                                                                "KEY_2" => "value2",
                                                                                "KEY_3" => "value3")
      end

    end

    describe "when only has environment entries in lower case" do

      let(:header_env_elements) { {} }

      it "returns an empty hash" do
        expect(HttpStub::Server::Stub::RequestHeaderParser.parse(request)).to eql({})
      end
      
    end

  end

end
