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

      before(:example) { allow(HttpStub::Configurer::Request::ControllableValue).to receive(:format) }

      it "creates a HTTP POST request" do
        expect(request.method).to eql("POST")
      end

      it "submits the request to '/stubs'" do
        expect(request.path).to eql("/stubs")
      end

      it "sets the content type to json" do
        expect(request.content_type).to eql("application/json")
      end

      context "when a request header argument is provided" do

        it "formats the headers into control values" do
          expect(HttpStub::Configurer::Request::ControllableValue).to receive(:format).with(request_headers)

          request
        end

      end

      context "when no request header is provided" do

        let(:request_headers) { nil }

        it "formats an empty header hash" do
          expect(HttpStub::Configurer::Request::ControllableValue).to receive(:format).with({})

          request
        end

      end

      context "when a request parameter argument is provided" do

        it "formats the request parameters into control values" do
          expect(HttpStub::Configurer::Request::ControllableValue).to receive(:format).with(request_parameters)

          request
        end

      end

      context "when no request parameter argument is provided" do

        let(:request_parameters) { nil }

        it "formats an empty parameter hash" do
          expect(HttpStub::Configurer::Request::ControllableValue).to receive(:format).with({})

          request
        end

      end

      context "generates a JSON body which" do

        it "has an entry containing the control value representation of the uri" do
          expect(HttpStub::Configurer::Request::ControllableValue).to receive(:format).with(uri).and_return("uri as a string")

          expect(request_body).to include("uri" => "uri as a string")
        end

        it "has an entry for the method argument" do
          expect(request_body).to include("method" => stub_method)
        end

        it "has an entry containing the string representation of the request headers" do
          expect(HttpStub::Configurer::Request::ControllableValue).to receive(:format)
            .with(request_headers).and_return("request headers as string")

          expect(request_body).to include("headers" => "request headers as string")
        end

        it "has an entry containing the string representation of the request parameters" do
          expect(HttpStub::Configurer::Request::ControllableValue).to receive(:format)
            .with(request_parameters).and_return("request parameters as string")

          expect(request_body).to include("parameters" => "request parameters as string")
        end

        context "when a status response argument is provided" do

          it "has a response entry for the argument" do
            expect(request_body["response"]).to include("status" => response_status)
          end

        end

        context "when no status response argument is provided" do

          let(:response_status) { nil }

          it "has a response entry with an empty status code" do
            expect(request_body["response"]).to include("status" => "")
          end

        end

        it "has an entry for the response body argument" do
          expect(request_body["response"]).to include("body" => response_body)
        end

        context "when a delay argument is provided" do

          it "has a response entry for the argument" do
            expect(request_body["response"]).to include("delay_in_seconds" => response_delay_in_seconds)
          end

        end

        context "when a delay argument is not provided" do

          let(:response_delay_in_seconds) { nil }

          it "has a response entry with an empty delay" do
            expect(request_body["response"]).to include("delay_in_seconds" => "")
          end

        end

        context "when response headers are provided" do

          let(:response_headers) { { "response_header_name" => "value" } }

          it "has a headers response entry containing the the provided headers" do
            expect(request_body["response"]["headers"]).to eql(response_headers)
          end

        end

        context "when response headers are not provided" do

          let (:response_headers) { nil }

          it "has a headers response entry containing an empty hash" do
            expect(request_body["response"]["headers"]).to eql({})
          end
        end

      end

    end

  end

end
