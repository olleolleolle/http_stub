describe HttpStub::Server::Stub::Payload::ResponseBodyModifier do

  describe "::modify!" do

    let(:parameters) { {} }
    let(:request)    { instance_double(HttpStub::Server::Request::Request, parameters: parameters) }

    let!(:original_payload) { payload.clone }

    subject { described_class.modify!(payload, request) }

    context "when the payload contains a response file and has a corresponding file parameter" do

      let(:payload_fixture) { HttpStub::StubFixture.new.with_file_response! }
      let(:payload)         { payload_fixture.server_payload }
      let(:parameters)      { { "response_file_#{payload_fixture.id}" => payload_fixture.file_parameter } }

      it "modifies the payload to have a response body that contains the file parameter value" do
        expected_payload = payload.clone.tap { |hash| hash["response"]["body"] = payload_fixture.file_parameter }

        subject

        expect(payload).to eql(expected_payload)
      end

    end

    context "when the payload contains triggered stubs" do

      let(:payload_fixture) { HttpStub::StubFixture.new.with_triggered_stubs!(trigger_fixtures) }
      let(:payload)         { payload_fixture.server_payload }

      context "and the trigger payloads contain response text" do

        let(:trigger_fixtures) { (1..3).map { HttpStub::StubFixture.new.with_text_response! } }

        it "leaves the payload unchanged" do
          subject

          expect(payload).to eql(original_payload)
        end

      end

      context "and the trigger payloads contain a response file with corresponding file parameters" do

        let(:trigger_fixtures) { (1..3).map { HttpStub::StubFixture.new.with_file_response! } }
        let(:file_parameters)  { trigger_fixtures.map(&:file_parameter) }
        let(:parameters) do
          trigger_fixtures.reduce({}) do |result, fixture|
            result.merge("response_file_#{fixture.id}" => fixture.file_parameter)
          end
        end

        it "modifies the payload to have trigger response bodies replaced by the files" do
          expected_payload = payload.clone
          expected_payload["triggers"]["stubs"].zip(file_parameters).each do |trigger, file_parameter|
            trigger["response"]["body"] = file_parameter
          end

          subject

          expect(payload).to eql(expected_payload)
        end

      end

    end

    context "when the payload does not contain a response file and has no triggered stubs" do

      let(:payload) { HttpStub::StubFixture.new.server_payload }

      it "leaves the payload unchanged" do
        subject

        expect(payload).to eql(original_payload)
      end

    end

  end

end
