describe HttpStub::Server::Session::IdentifierStrategy do

  let(:configuration) { nil }

  let(:identifier_strategy) { described_class.new(configuration) }

  describe "#identifier_for" do

    let(:request_headers)    { {} }
    let(:request_parameters) { {} }
    let(:request)            do
      instance_double(HttpStub::Server::Request::Request, headers: request_headers, parameters: request_parameters)
    end

    subject { identifier_strategy.identifier_for(request) }

    context "when a custom configuration is provided" do

      let(:configuration) { { header: :custom_session_header } }

      context "and the request contains both an internal http_stub session id and a custom request id" do

        let(:request_parameters) { { http_stub_session_id: "http_stub session value" } }
        let(:request_headers)    { { custom_session_header: "custom session value" } }

        it "returns the http_stub session id" do
          expect(subject).to eql("http_stub session value")
        end

      end

      context "and the request does not contain an internal http_stub session id" do

        context "and a header identifier is configured" do

          let(:configuration) { { header: :some_session_header } }

          context "and the request has a value for the header" do

            let(:header_value)    { "some session value" }
            let(:request_headers) { { some_session_header: header_value, another_header: "some value" } }

            it "returns the headers value" do
              expect(subject).to eql(header_value)
            end

          end

          context "and the request does not have a value for the header" do

            let(:request_headers) { { another_header: "some value" } }

            it "returns 'Default'" do
              expect(subject).to eql("Default")
            end

          end

        end

        context "and a parameter identifier is configured" do

          let(:configuration) { { parameter: :some_session_parameter } }

          context "and the request has a value for the parameter" do

            let(:parameter_value)    { "some session value" }
            let(:request_parameters) { { some_session_parameter: parameter_value, another_parameter: "some value" } }

            it "returns the parameters value" do
              expect(subject).to eql(parameter_value)
            end

          end

          context "and the request does not have a value for the parameter" do

            let(:request_parmeters) { { another_parameter: "some value" } }

            it "returns 'Default'" do
              expect(subject).to eql("Default")
            end

          end

        end

      end

    end

    context "when no custom configuration is provided" do

      let(:configuration) { nil }

      context "and the request contains an internal http_stub session id" do

        let(:request_parameters) do
          { http_stub_session_id: "http_stub session value", another_parameter: "some value" }
        end

        it "returns the http_stub session id" do
          expect(subject).to eql("http_stub session value")
        end

      end

      context "and the request does not contain any session id" do

        it "return 'Default'" do
          expect(subject).to eql("Default")
        end

      end

    end

  end

end
