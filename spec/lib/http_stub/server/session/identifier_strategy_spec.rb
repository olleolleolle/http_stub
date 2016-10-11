describe HttpStub::Server::Session::IdentifierStrategy do

  let(:identifier_configuration) { {} }
  let(:session_configuration) do
    instance_double(HttpStub::Server::Session::Configuration, identifier_configuration: identifier_configuration)
  end

  let(:identifier_strategy) { described_class.new(session_configuration) }

  describe "#identifier_for" do

    let(:request_headers)    { {} }
    let(:request_parameters) { {} }
    let(:sinatra_request)    do
      instance_double(HttpStub::Server::Request::SinatraRequest, headers:    request_headers,
                                                                 parameters: request_parameters)
    end

    subject { identifier_strategy.identifier_for(sinatra_request) }

    context "when the session identifier configuration has multiple entries" do

      let(:identifier_configuration) do
        [
          { header:    :first_session_header },
          { parameter: :first_session_parameter },
          { header:    :second_session_header },
          { parameter: :second_session_parameter }
        ]
      end

      context "and multiple session values are in the request" do

        let(:request_headers)    do
          { second_session_header: "second session header value", another_header: "another header value" }
        end
        let(:request_parameters) do
          { first_session_parameter: "first session parameter value", another_parameter: "another parameter value" }
        end

        it "returns the first value from the configuration in the request" do
          expect(subject).to eql("first session parameter value")
        end

      end

      context "and one session value is in the request" do

        let(:request_headers)    { { a_header: "a header value" } }
        let(:request_parameters) do
          { second_session_parameter: "second session parameter value", another_parameter: "another parameter value" }
        end

        it "returns the value" do
          expect(subject).to eql("second session parameter value")
        end

      end

      context "and the session value is not in the request" do

        it "returns nil" do
          expect(subject).to eql(nil)
        end

      end

    end

    context "when the session identifier configuration has one entry" do

      context "that is a header" do

        let(:identifier_configuration) { [ { header: :session_header } ] }

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

        let(:identifier_configuration) { [ { parameter: :session_parameter } ] }

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
