describe HttpStub::Configurer::Request::Stub do

  describe "#initialize" do

    context "when provided a uri and stub arguments" do

      let(:uri) { "/some/uri" }
      let(:stub_method) { "Some Method" }
      let(:request_headers) { { "request_header_name" => "value" } }
      let(:request_parameters) { { "parameter_name" => "value" } }
      let(:response_status) { 500 }
      let(:response_headers) { { "response_header_name" => "value" } }
      let(:response_body) { "Some body" }
      let(:response_delay_in_seconds) { 7 }

      let(:stub_args) do
        {
            method: stub_method,
            headers: request_headers,
            parameters: request_parameters,
            response: {
                status: response_status,
                headers: response_headers,
                body: response_body,
                delay_in_seconds: response_delay_in_seconds
            }
        }
      end

      let(:request) { HttpStub::Configurer::Request::Stub.new(uri, stub_args) }
      let(:request_body) { JSON.parse(request.body) }

      before(:each) { HttpStub::Configurer::Request::ControllableValue.stub(:format) }

      it "should create a HTTP POST request" do
        request.method.should eql("POST")
      end

      it "should submit the request to '/stubs'" do
        request.path.should eql("/stubs")
      end

      it "should set the content type to json" do
        request.content_type.should eql("application/json")
      end

      context "when a request header argument is provided" do

        it "should format the headers into control values" do
          HttpStub::Configurer::Request::ControllableValue.should_receive(:format).with(request_headers)

          request
        end

      end

      context "when no request header is provided" do

        let(:request_headers) { nil }

        it "should format an empty header hash" do
          HttpStub::Configurer::Request::ControllableValue.should_receive(:format).with({})

          request
        end

      end

      context "when a request parameter argument is provided" do

        it "should format the request parameters into control values" do
          HttpStub::Configurer::Request::ControllableValue.should_receive(:format).with(request_parameters)

          request
        end

      end

      context "when no request parameter argument is provided" do

        let(:request_parameters) { nil }

        it "should format an empty parameter hash" do
          HttpStub::Configurer::Request::ControllableValue.should_receive(:format).with({})

          request
        end

      end

      context "generates a JSON body which" do

        it "should have an entry containing the control value representation of the uri" do
          HttpStub::Configurer::Request::ControllableValue.should_receive(:format).with(uri).and_return("uri as a string")

          request_body.should include("uri" => "uri as a string")
        end

        it "should have an entry for the method argument" do
          request_body.should include("method" => stub_method)
        end

        it "should have an entry containing the string representation of the request headers" do
          HttpStub::Configurer::Request::ControllableValue.should_receive(:format)
            .with(request_headers).and_return("request headers as string")

          request_body.should include("headers" => "request headers as string")
        end

        it "should have an entry containing the string representation of the request parameters" do
          HttpStub::Configurer::Request::ControllableValue.should_receive(:format)
            .with(request_parameters).and_return("request parameters as string")

          request_body.should include("parameters" => "request parameters as string")
        end

        context "when a status response argument is provided" do

          it "should have a response entry for the argument" do
            request_body["response"].should include("status" => response_status)
          end

        end

        context "when no status response argument is provided" do

          let(:response_status) { nil }

          it "should have a response entry with an empty status code" do
            request_body["response"].should include("status" => "")
          end

        end

        it "should have an entry for the response body argument" do
          request_body["response"].should include("body" => response_body)
        end

        context "when a delay argument is provided" do

          it "should have a response entry for the argument" do
            request_body["response"].should include("delay_in_seconds" => response_delay_in_seconds)
          end

        end

        context "when a delay argument is not provided" do

          let(:response_delay_in_seconds) { nil }

          it "should have a response entry with an empty delay" do
            request_body["response"].should include("delay_in_seconds" => "")
          end

        end

        context "when response headers are provided" do

          let(:response_headers) { { "response_header_name" => "value" } }

          it "should have a headers response entry containing the the provided headers" do
            request_body["response"]["headers"].should eql(response_headers)
          end

        end

        context "when response headers are not provided" do

          let (:response_headers) { nil }

          it "should have a headers response entry containing an empty hash" do
            request_body["response"]["headers"].should eql({})
          end
        end

      end

    end

  end

end
