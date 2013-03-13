describe HttpStub::Configurer::StubHttpRequestFactory do

  let(:factory) { HttpStub::Configurer::StubHttpRequestFactory }

  describe ".create" do

    describe "when provided a uri and stub options" do

      let(:uri) { "Some URI" }
      let(:stub_method) { "Some Method" }
      let(:headers) { { "header_name" => "value" } }
      let(:parameters) { { "parameter_name" => "value" } }
      let(:response_status) { 500 }
      let(:response_body) { "Some body" }

      let(:stub_options) do
        {
            method: stub_method,
            headers: headers,
            parameters: parameters,
            response: {
                status: response_status,
                body: response_body
            }
        }
      end

      it "should create a HTTP POST request" do
        request = factory.create(uri, stub_options)

        request.class::METHOD.should eql("POST")
      end

      it "should submit the request to '/stubs'" do
        request = factory.create(uri, stub_options)

        request.path.should eql("/stubs")
      end

      it "should set the content type to json" do
        request = factory.create(uri, stub_options)

        request.content_type.should eql("application/json")
      end

      describe "generates a JSON body which" do

        it "should have an entry for the provided URI" do
          request = factory.create(uri, stub_options)

          JSON.parse(request.body).should include({ "uri" => uri })
        end

        it "should have an entry for the method option" do
          request = factory.create(uri, stub_options)

          JSON.parse(request.body).should include({ "method" => stub_method })
        end

        describe "when a header option is provided" do

          it "should have an entry for the option" do
            request = factory.create(uri, stub_options)

            JSON.parse(request.body).should include({ "headers" => headers })
          end

        end

        describe "when no header is provided" do

          let(:headers) { nil }

          it "should have an empty header entry" do
            request = factory.create(uri, stub_options)

            JSON.parse(request.body).should include({ "headers" => {} })
          end

        end

        describe "when a parameter option is provided" do

          it "should have an entry for the option" do
            request = factory.create(uri, stub_options)

            JSON.parse(request.body).should include({ "parameters" => parameters })
          end

        end

        describe "when no parameter option is provided" do

          let(:parameters) { nil }

          it "should have an empty header entry" do
            request = factory.create(uri, stub_options)

            JSON.parse(request.body).should include({ "parameters" => {} })
          end

        end

        describe "when a status response option is provided" do

          it "should have a response entry for the option" do
            request = factory.create(uri, stub_options)

            request_body = JSON.parse(request.body)
            request_body["response"].should include({ "status" => response_status })
          end

        end

        describe "when no status response option is provided" do

          let(:response_status) { nil }

          it "should have a response entry with status code '200'" do
            request = factory.create(uri, stub_options)

            request_body = JSON.parse(request.body)
            request_body["response"].should include({ "status" => "200" })
          end

        end

        it "should have an entry for the response body option" do
          request = factory.create(uri, stub_options)

          request_body = JSON.parse(request.body)
          request_body["response"].should include({ "body" => response_body })
        end

      end

    end

  end

end
