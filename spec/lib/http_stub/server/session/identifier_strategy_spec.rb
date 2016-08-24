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

    context "when an header identifier is configured" do

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

        it "returns nil" do
          expect(subject).to eql(nil)
        end

      end

    end

    context "when a parameter identifier is configured" do

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

        it "returns nil" do
          expect(subject).to eql(nil)
        end

      end

    end

    context "when no identifier is configured" do

      let (:configuration) { nil }

      it "returns nil" do
        expect(subject).to eql(nil)
      end

    end

  end

end
