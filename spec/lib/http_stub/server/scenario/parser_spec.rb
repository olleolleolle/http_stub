describe HttpStub::Server::Scenario::Parser do

  let(:parser) { described_class }

  describe "::parse" do

    let(:payload)           { HttpStub::ScenarioFixture.new.server_payload }
    let(:payload_parameter) { payload.to_json }
    let(:parameters)        { { "payload" => payload_parameter } }
    let(:request)           { instance_double(HttpStub::Server::Request::Request, parameters: parameters) }

    let(:parsed_payload) { payload.clone }

    subject { parser.parse(request) }

    before(:example) { allow(JSON).to receive(:parse).and_return(parsed_payload) }

    it "parses the JSON payload in the request" do
      expect(JSON).to receive(:parse).with(payload_parameter)

      subject
    end

    it "returns the modified payload" do
      expect(subject).to eql(parsed_payload)
    end

    context "when the request contains many stubs" do

      let(:payload) { HttpStub::ScenarioFixture.new.with_stubs!(3).server_payload }

      let(:stub_payloads) { payload["stubs"] }

      before(:example) do
        stub_payloads.each { |stub_payload| allow(HttpStub::Server::Stub::Payload).to receive(:modify!) }
      end

      it "modifies each stub payload" do
        stub_payloads.each do |stub_payload|
          expect(HttpStub::Server::Stub::Payload).to receive(:modify!).with(stub_payload, request)
        end

        subject
      end

    end

    context "when the request contains one stub" do

      let(:payload) { HttpStub::ScenarioFixture.new.with_stubs!(1).server_payload }

      let(:stub_payload) { payload["stubs"].first }

      it "modifies the stub payload" do
        expect(HttpStub::Server::Stub::Payload).to receive(:modify!).with(stub_payload, request)

        subject
      end

    end

  end

end
