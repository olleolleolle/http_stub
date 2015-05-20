describe HttpStub::Server::RequestParser do

  let(:request_parser) { HttpStub::Server::RequestParser }

  describe "::parse" do

    let(:params)    { {} }
    let(:body_hash) { {} }
    let(:request)   { instance_double(Rack::Request, params: params, body: StringIO.new(body_hash.to_json)) }

    subject { request_parser.parse(request) }

    context "when the request contains a payload parameter" do

      let(:payload) { HttpStub::StubFixture.new.server_payload }
      let(:params)  { { "payload" => payload.to_json } }

      it "returns the payload" do
        expect(subject).to eql(payload)
      end

    end

    context "when the request body contains the payload (for API backwards compatibility)" do

      let(:body_hash) { HttpStub::StubFixture.new.server_payload }

      it "returns the request body" do
        expect(subject).to eql(body_hash)
      end

    end

    context "when the payload contains a response file and has a corresponding file parameter" do

      let(:payload_fixture) { HttpStub::StubFixture.new.with_file_response! }
      let(:payload)         { payload_fixture.server_payload }
      let(:file_params)     { { "response_file_#{payload_fixture.id}" => payload_fixture.file_parameter } }
      let(:params)          { { "payload" => payload.to_json }.merge(file_params) }

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
        let(:params)           { { "payload" => payload.to_json } }

        it "returns the payload unchanged" do
          expect(subject).to eql(payload)
        end

      end

      context "and the trigger payloads contain a response file with corresponding file parameters" do

        let(:trigger_fixtures) { (1..3).map { HttpStub::StubFixture.new.with_file_response! } }
        let(:file_params) do
          trigger_fixtures.reduce({}) do |result, fixture|
            result.merge("response_file_#{fixture.id}" => fixture.file_parameter)
          end
        end
        let(:params)           { { "payload" => payload.to_json }.merge(file_params) }

        it "returns the payload with the trigger response bodies replaced by the files" do
          expected_payload = payload_fixture.server_payload
          expected_payload["triggers"].zip(trigger_fixtures.map(&:file_parameter)).each do |trigger, file_param|
            trigger["response"]["body"] = file_param
          end

          expect(subject).to eql(expected_payload)
        end

      end

    end

  end

end
