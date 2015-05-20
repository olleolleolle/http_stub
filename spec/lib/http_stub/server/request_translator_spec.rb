describe HttpStub::Server::RequestTranslator do

  let(:model)       { double("HttpStub::Server::Model") }
  let(:model_class) { double("HttpStub::Server::ModelClass", new: model) }

  let(:request_translator) { HttpStub::Server::RequestTranslator.new(model_class) }

  describe "::translate" do

    let(:params)    { {} }
    let(:body_hash) { {} }
    let(:request)   { instance_double(Rack::Request, params: params, body: StringIO.new(body_hash.to_json)) }

    subject { request_translator.translate(request) }

    shared_context "returns the created model" do

      it "returns the created model" do
        expect(subject).to eql(model)
      end

    end

    context "when the request contains a payload parameter" do

      let(:payload) { HttpStub::StubFixture.new.server_payload }
      let(:params)  { { "payload" => payload.to_json } }

      it "creates the model with the payload" do
        expect(model_class).to receive(:new).with(payload)

        subject
      end

      include_context "returns the created model"

    end

    context "when the request body contains the payload (for API backwards compatibility)" do

      let(:body_hash) { HttpStub::StubFixture.new.server_payload }

      it "creates the model with the request body" do
        expect(model_class).to receive(:new).with(body_hash)

        subject
      end

      include_context "returns the created model"

    end

    context "when the payload contains a response file and has a corresponding file parameter" do

      let(:payload_fixture) { HttpStub::StubFixture.new.with_file_response! }
      let(:payload)         { payload_fixture.server_payload }
      let(:file_params)     { { "response_file_#{payload_fixture.id}" => payload_fixture.file_parameter } }
      let(:params)          { { "payload" => payload.to_json }.merge(file_params) }

      it "creates the model with a response body that contains the file parameter value" do
        expected_args = payload.clone.tap { |hash| hash["response"]["body"] = payload_fixture.file_parameter }
        expect(model_class).to receive(:new).with(expected_args)

        subject
      end

      include_context "returns the created model"

    end

    context "when the payload contains triggers" do

      let(:payload_fixture) { HttpStub::StubFixture.new.with_triggers!(trigger_fixtures) }
      let(:payload)         { payload_fixture.server_payload }

      context "and the trigger payloads contain response text" do

        let(:trigger_fixtures) { (1..3).map { HttpStub::StubFixture.new.with_text_response! } }
        let(:params)           { { "payload" => payload.to_json } }

        it "creates the model with the payload unchanged" do
          expect(model_class).to receive(:new).with(payload)

          subject
        end

        include_context "returns the created model"

      end

      context "and the trigger payloads contain a response file with corresponding file parameters" do

        let(:trigger_fixtures) { (1..3).map { HttpStub::StubFixture.new.with_file_response! } }
        let(:file_params) do
          trigger_fixtures.reduce({}) do |result, fixture|
            result.merge("response_file_#{fixture.id}" => fixture.file_parameter)
          end
        end
        let(:params)           { { "payload" => payload.to_json }.merge(file_params) }

        it "creates the model with the trigger response bodies replaced by the files" do
          expected_args = payload_fixture.server_payload
          expected_args["triggers"].zip(trigger_fixtures.map(&:file_parameter)).each do |trigger, file_param|
            trigger["response"]["body"] = file_param
          end
          expect(model_class).to receive(:new).with(expected_args)

          subject
        end

        include_context "returns the created model"

      end

    end

  end

end
