describe HttpStub::Server::StubFactory do

  describe "::create" do

    let(:params)    { {} }
    let(:body_hash) { {} }
    let(:request)   { instance_double(Rack::Request, params: params, body: StringIO.new(body_hash.to_json)) }

    subject { HttpStub::Server::StubFactory.create(request) }

    shared_context "returns the created stub" do

      it "returns the created stub" do
        stub = instance_double(HttpStub::Server::Stub)
        allow(HttpStub::Server::Stub).to receive(:new).and_return(stub)

        expect(subject).to eql(stub)
      end

    end

    context "when the request contains a payload parameter" do

      let(:payload) { HttpStub::StubFixture.new.server_payload }
      let(:params)  { { "payload" => payload.to_json } }

      it "creates the stub with the payload" do
        expect(HttpStub::Server::Stub).to receive(:new).with(payload)

        subject
      end

      include_context "returns the created stub"

    end

    context "when the request body contains the payload (for API backwards compatibility)" do

      let(:body_hash) { HttpStub::StubFixture.new.server_payload }

      it "creates the stub with the request body" do
        expect(HttpStub::Server::Stub).to receive(:new).with(body_hash)

        subject
      end

      include_context "returns the created stub"

    end

    context "when a stub payload contains a response file and has a corresponding file parameter" do

      let(:stub_fixture) { HttpStub::StubFixture.new.with_file_response! }
      let(:payload)      { stub_fixture.server_payload }
      let(:file_params)  { { "response_file_#{stub_fixture.id}" => stub_fixture.file_parameter } }
      let(:params)       { { "payload" => payload.to_json }.merge(file_params) }

      it "creates the stub with a response body that contains the file parameter value" do
        expected_args = payload.clone.tap { |hash| hash["response"]["body"] = stub_fixture.file_parameter }
        expect(HttpStub::Server::Stub).to receive(:new).with(expected_args)

        subject
      end

      include_context "returns the created stub"

    end

    context "when a stub payload contains triggers" do

      let(:stub_fixture) { HttpStub::StubFixture.new.with_triggers!(trigger_fixtures) }
      let(:payload)      { stub_fixture.server_payload }

      context "and the trigger payloads contain response text" do

        let(:trigger_fixtures) { (1..3).map { HttpStub::StubFixture.new.with_text_response! } }
        let(:params)           { { "payload" => payload.to_json } }

        it "creates the stub with the stub payload unchanged" do
          expect(HttpStub::Server::Stub).to receive(:new).with(payload)

          subject
        end

        include_context "returns the created stub"

      end

      context "and the trigger payloads contain a response file with corresponding file parameters" do

        let(:trigger_fixtures) { (1..3).map { HttpStub::StubFixture.new.with_file_response! } }
        let(:file_params) do
          trigger_fixtures.reduce({}) do |result, fixture|
            result.merge("response_file_#{fixture.id}" => fixture.file_parameter)
          end
        end
        let(:params)           { { "payload" => payload.to_json }.merge(file_params) }

        it "creates the stub with the trigger response bodies replaced by the files" do
          expected_args = stub_fixture.server_payload
          expected_args["triggers"].zip(trigger_fixtures.map(&:file_parameter)).each do |trigger, file_param|
            trigger["response"]["body"] = file_param
          end
          expect(HttpStub::Server::Stub).to receive(:new).with(expected_args)

          subject
        end

        include_context "returns the created stub"

      end

    end

  end

end
