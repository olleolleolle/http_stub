describe HttpStub::Server::Stub::Match::Rule::Body do

  describe "::create" do

    subject { described_class.create(stubbed_body) }

    shared_context "a raw request body that causes a simple request body to be created" do

      it "creates a simple request body with the body" do
        expect(HttpStub::Server::Stub::Match::Rule::SimpleBody).to receive(:new).with(stubbed_body)

        subject
      end

      it "returns the created request body" do
        simple_body = instance_double(HttpStub::Server::Stub::Match::Rule::SimpleBody)
        allow(HttpStub::Server::Stub::Match::Rule::SimpleBody).to receive(:new).and_return(simple_body)

        expect(subject).to eql(simple_body)
      end

    end

    context "when the stubbed body contains a schema" do

      let(:stubbed_body) { { "schema" => raw_schema } }

      context "that is JSON" do

        let(:json_schema) { "some json schema" }
        let(:raw_schema)  { { "type" => "json", "definition" => json_schema } }

        it "creates a JSON request body with the schema" do
          expect(HttpStub::Server::Stub::Match::Rule::JsonBody).to receive(:new).with(json_schema)

          subject
        end

        it "returns the created request body" do
          json_body = instance_double(HttpStub::Server::Stub::Match::Rule::JsonBody)
          allow(HttpStub::Server::Stub::Match::Rule::JsonBody).to receive(:new).and_return(json_body)

          expect(subject).to eql(json_body)
        end

      end

      context "that is not JSON" do

        let(:raw_schema) { { "type" => "xml", "definition" => "some xml schema" } }

        it "raises an error indicating the body is invalid" do
          expect { subject }.to(
            raise_error("Stub request body schema #{raw_schema} is invalid: xml schema is not supported")
          )
        end

      end

      context "that does not have a type" do

        let(:raw_schema) { { "definition" => "some defintion" } }

        it "raises an error indicating the body is invalid" do
          expect { subject }.to raise_error("Stub request body schema #{raw_schema} is invalid: type expected")
        end

      end

      context "that does not have a definition" do

        let(:raw_schema) { { "type" => "some type" } }

        it "raises an error indicating the body is invalid" do
          expect { subject }.to raise_error("Stub request body schema #{raw_schema} is invalid: definition expected")
        end

      end

    end

    context "when the stubbed body contains a string" do

      let(:stubbed_body) { "some string" }

      it_behaves_like "a raw request body that causes a simple request body to be created"

    end

    context "when the stubbed body contains a regular expression control value" do

      let(:stubbed_body) { "regexp:some regex" }

      it_behaves_like "a raw request body that causes a simple request body to be created"

    end

    context "when the stubbed body is empty" do

      let(:stubbed_body) { "" }

      it "returns a truthy match rule" do
        expect(subject).to eql(HttpStub::Server::Stub::Match::Rule::Truthy)
      end

    end

    context "when the stubbed body is nil" do

      let(:stubbed_body) { nil }

      it "returns a truthy match rule" do
        expect(subject).to eql(HttpStub::Server::Stub::Match::Rule::Truthy)
      end

    end

  end

end
