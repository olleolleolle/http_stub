describe HttpStub::Server::Session::IdentifierStrategy do

  let(:identifier_setting) { {} }

  let(:identifier_strategy) { described_class.new(identifier_setting) }

  describe "#identifier_for" do

    let(:request_headers)    { {} }
    let(:request_parameters) { {} }
    let(:sinatra_request)    do
      HttpStub::Server::Request::SinatraRequestFixture.create(headers: request_headers, parameters: request_parameters)
    end

    subject { identifier_strategy.identifier_for(sinatra_request) }

    context "when a http stub session id header value is in the request" do

      let(:request_headers) { { http_stub_session_id: "some header value" } }

      it "returns the parameter value" do
        expect(subject).to eql("some header value")
      end

    end

    context "when a http stub session id parameter value is in the request" do

      let(:request_parameters) { { http_stub_session_id: "some parameter value" } }

      it "returns the parameter value" do
        expect(subject).to eql("some parameter value")
      end

    end

    context "when an identifier setting is provided" do

      context "that is a header" do

        let(:identifier_setting) { { header: :session_header } }

        context "and the session value is in the request" do

          let(:request_headers) { { session_header: "session header value", another_header: "another header value" } }

          it "returns the value" do
            expect(subject).to eql("session header value")
          end

        end

        context "and the session value is not in the request" do

          it "returns nil" do
            expect(subject).to eql(nil)
          end

        end

      end

      context "that is a parameter" do

        let(:identifier_setting) { { parameter: :session_parameter } }

        context "and the session value is in the request" do

          let(:request_parameters) do
            { session_parameter: "session parameter value", another_parameter: "another parameter value" }
          end

          it "returns the value" do
            expect(subject).to eql("session parameter value")
          end

        end

        context "and the session value is not in the request" do

          it "returns nil" do
            expect(subject).to eql(nil)
          end

        end

      end

    end

  end

end
