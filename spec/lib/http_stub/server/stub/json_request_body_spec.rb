describe HttpStub::Server::Stub::JsonRequestBody do

  let(:stubbed_schema_definition) { { "type" => "object", "properties" => { "some_property" => "some_type" } } }

  let(:json_request_body) { HttpStub::Server::Stub::JsonRequestBody.new(stubbed_schema_definition) }

  describe "#match?" do

    let(:logger)           { double("Logger").as_null_object }
    let(:raw_request_body) { { "some_json_property" => "some_json_value" }.to_json }
    let(:request_body)     { double("RackRequestBody", read: raw_request_body) }
    let(:request)          { instance_double(Rack::Request, logger: logger, body: request_body) }

    let(:validation_errors) { [] }

    subject { json_request_body.match?(request) }

    before(:example) { allow(JSON::Validator).to receive(:fully_validate).and_return(validation_errors) }

    it "validates the request body using the stubbed schema definition" do
      expect(JSON::Validator).to receive(:fully_validate).with(stubbed_schema_definition, raw_request_body, anything)

      subject
    end

    it "validates against raw JSON" do
      expect(JSON::Validator).to receive(:fully_validate).with(anything, anything, hash_including(json: true))

      subject
    end

    it "ensures the schema definition is valid" do
      expect(JSON::Validator).to(
        receive(:fully_validate).with(anything, anything, hash_including(validate_schema: true))
      )

      subject
    end

    context "when body is valid" do

      let(:validation_errors) { [] }

      it "returns true" do
        expect(subject).to be(true)
      end

      it "logs nothing" do
        expect(logger).not_to receive(:info)

        subject
      end

    end

    context "when the body is invalid" do

      let(:validation_errors) { (1..3).map { |i| "The property '#/#{i}' failed validation"} }

      it "returns false" do
        expect(subject).to be(false)
      end

      it "logs each validation error" do
        validation_errors.each { |validation_error| expect(logger).to receive(:info).with(validation_error) }

        subject
      end

    end

    context "when an error occurs validating the body" do

      let(:error) { JSON::ParserError.new }

      before(:example) { allow(JSON::Validator).to receive(:fully_validate).and_raise(JSON::ParserError.new) }

      it "returns false" do
        expect(subject).to be(false)
      end

      it "logs the error" do
        expect(logger).to receive(:info).with(error.message)

        subject
      end

    end

  end

  describe "#to_s" do

    subject { json_request_body.to_s }

    it "returns the JSON representation of the schema definition" do
      expect(subject).to eql(stubbed_schema_definition.to_json)
    end

  end

end
