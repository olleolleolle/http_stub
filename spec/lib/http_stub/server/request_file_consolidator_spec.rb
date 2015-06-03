describe HttpStub::Server::Stub::PayloadFileConsolidator do

  let(:consolidator) { described_class }

  describe "::consolidate!" do

    let(:params)  { {} }
    let(:request) { instance_double(Rack::Request, params: params) }

    subject { consolidator.consolidate!(payload, request) }

    context "when the payload contains a response file and has a corresponding file parameter" do

      let(:payload_fixture) { HttpStub::StubFixture.new.with_file_response! }
      let(:payload)         { payload_fixture.server_payload }
      let(:params)          { { "response_file_#{payload_fixture.id}" => payload_fixture.file_parameter } }

      it "returns the payload with a response body that contains the file parameter value" do
        expected_payload = payload.clone.tap { |hash| hash["response"]["body"] = payload_fixture.file_parameter }

        expect(subject).to eql(expected_payload)
      end

    end

    context "when the payload contains triggers" do

      let(:payload_fixture) { HttpStub::StubFixture.new.with_triggers!(trigger_fixtures) }
      let(:payload)         { payload_fixture.server_payload }

      context "and the trigger payloads contain response text" do

        let(:trigger_fixtures) { (1..3).map { HttpStub::StubFixture.new.with_text_response! } }

        it "returns the payload unchanged" do
          expect(subject).to eql(payload)
        end

      end

      context "and the trigger payloads contain a response file with corresponding file parameters" do

        let(:trigger_fixtures) { (1..3).map { HttpStub::StubFixture.new.with_file_response! } }
        let(:params) do
          trigger_fixtures.reduce({}) do |result, fixture|
            result.merge("response_file_#{fixture.id}" => fixture.file_parameter)
          end
        end

        it "returns the payload with the trigger response bodies replaced by the files" do
          expected_payload = payload_fixture.server_payload
          expected_payload["triggers"].zip(trigger_fixtures.map(&:file_parameter)).each do |trigger, file_param|
            trigger["response"]["body"] = file_param
          end

          expect(subject).to eql(expected_payload)
        end

      end

    end

    context "when the payload does not contain a response file and has no triggers" do

      let(:payload) { HttpStub::StubFixture.new.server_payload }

      it "returns an unchanged payload" do
        original_payload = payload.clone

        expect(subject).to eql(original_payload)
      end

    end

  end

end
