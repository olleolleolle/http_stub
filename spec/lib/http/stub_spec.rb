describe Http::Stub::Stub do

  let(:stub_uri) { "/a_path" }
  let(:stub_method) { "get" }
  let(:stub_parameters) { {} }
  let(:stub_body) do
    {
        "uri" => stub_uri,
        "method" => stub_method,
        "parameters" => stub_parameters,
        "response" => {
            "status" => 201,
            "body" => "Foo"
        }
    }.to_json
  end
  let(:stub_request) { double("HttpRequest", :body => double("HttpRequestBody", :read => stub_body)) }
  let(:stub_instance) { Http::Stub::Stub.new(stub_request) }

  describe "#stubs?" do

    let(:request_uri) { stub_uri }
    let(:request_method) { stub_method }
    let(:request_parameters) { stub_parameters }
    let(:request) do
      double("HttpRequest", :path_info => request_uri, :request_method => request_method, :params => request_parameters)
    end

    describe "when the request uri matches" do

      describe "and the request method matches" do

        describe "and a parameter match is configured" do

          let(:stub_parameters) do
            {
                "param1" => "value1",
                "param2" => "value2",
                "param3" => "value3"
            }
          end

          describe "and the parameters match" do

            it "should return true" do
              stub_instance.stubs?(request).should be_true
            end

          end

          describe "and the parameter values do not match" do

            let(:request_parameters) do
              {
                  "param1" => "value1",
                  "param2" => "aDifferentValue",
                  "param3" => "value3"
              }
            end

            it "should return false" do
              stub_instance.stubs?(request).should be_false
            end

          end

          describe "and not all parameters are provided" do

            let(:request_parameters) do
              {
                  "param1" => "value1",
                  "param3" => "value3"
              }
            end

            it "should be false" do
              stub_instance.stubs?(request).should be_false
            end

          end

        end

      end

    end

    describe "when the request uri does not match" do

      let(:request_uri) { "/a_different_path" }

      it "should return false" do
        stub_instance.stubs?(request).should be_false
      end

    end

    describe "when the request method does not match" do

      let(:request_method) { "post" }

      it "should return false" do
        stub_instance.stubs?(request).should be_false
      end

    end

  end

  describe "#response" do

    it "should expose the provided response status" do
      stub_instance.response.status.should eql(201)
    end

    it "should expose the provided response body" do
      stub_instance.response.body.should eql("Foo")
    end

  end

  describe "#to_s" do

    let(:stub_parameters) do
      {
          "param1" => "value1",
          "param2" => "value2",
          "param3" => "value3"
      }
    end

    it "should return a string containing the stubbed uri" do
      stub_instance.to_s.should match(/\/a_path/)
    end

    it "should return a string containing the stubbed request method" do
      stub_instance.to_s.should match(/get/)
    end

    it "should return a string containing the stubbed parameters" do
      stub_parameters.each_pair do |key, value|
        stub_instance.to_s.should match(/#{Regexp.escape(key)}/)
        stub_instance.to_s.should match(/#{Regexp.escape(value)}/)
      end
    end

    it "should return a string containing the intended response code" do
      stub_instance.to_s.should match(/201/)
    end

    it "should return a string containing the intended response body" do
      stub_instance.to_s.should match(/Foo/)
    end

  end

end
