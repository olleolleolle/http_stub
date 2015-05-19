describe HttpStub::Configurer::Request::Stub do

  let(:fixture)          { HttpStub::StubFixture.new }
  let(:stub_response)    { instance_double(HttpStub::Configurer::Request::StubResponse).as_null_object }
  let(:trigger_builders) { [] }

  let(:stub) do
    HttpStub::Configurer::Request::Stub.new(fixture.configurer_payload.merge(triggers: trigger_builders))
  end

  before(:example) { allow(HttpStub::Configurer::Request::StubResponse).to receive(:new).and_return(stub_response) }

  shared_context "triggers one stub" do

    let(:trigger_payload) { HttpStub::StubFixture.new.configurer_payload }
    let(:trigger_files)   { [] }
    let(:trigger) do
      instance_double(HttpStub::Configurer::Request::Stub,
                      payload: trigger_payload, response_files: trigger_files)
    end
    let(:trigger_builders) do
      [ instance_double(HttpStub::Configurer::Request::StubBuilder, build: trigger) ]
    end

  end

  shared_context "triggers many stubs" do

    let(:trigger_payloads) { (1..3).map { HttpStub::StubFixture.new.configurer_payload } }
    let(:triggers_files)   { trigger_payloads.map { [] } }
    let(:triggers) do
      trigger_payloads.zip(triggers_files).map do |payload, files|
        instance_double(HttpStub::Configurer::Request::Stub, payload: payload, response_files: files)
      end
    end
    let(:trigger_builders) do
      triggers.map do |trigger|
        instance_double(HttpStub::Configurer::Request::StubBuilder, build: trigger)
      end
    end

  end

  describe "#payload" do

    subject { stub.payload }

    before(:example) { allow(HttpStub::Configurer::Request::ControllableValue).to receive(:format) }

    context "when request headers are provided" do

      it "formats the headers into control values" do
        expect(HttpStub::Configurer::Request::ControllableValue).to receive(:format).with(fixture.request.headers)

        subject
      end

    end

    context "when no request header is provided" do

      before(:example) do
        fixture.request.headers = nil
      end

      it "formats an empty header hash" do
        expect(HttpStub::Configurer::Request::ControllableValue).to receive(:format).with({})

        subject
      end

    end

    context "when a request parameter is provided" do

      it "formats the request parameters into control values" do
        expect(HttpStub::Configurer::Request::ControllableValue).to receive(:format).with(fixture.request.parameters)

        subject
      end

    end

    context "when no request parameter is provided" do

      before(:example) { fixture.request.parameters = nil }

      it "formats an empty parameter hash" do
        expect(HttpStub::Configurer::Request::ControllableValue).to receive(:format).with({})

        subject
      end

    end

    it "creates a stub response with the provided response options" do
      expect(HttpStub::Configurer::Request::StubResponse).to(
        receive(:new).with(anything, fixture.response.symbolized).and_return(stub_response)
      )

      subject
    end

    context "when many triggers are provided" do

      include_context "triggers many stubs"

      it "builds the request object for each trigger" do
        trigger_builders.each { |trigger_builder| expect(trigger_builder).to receive(:build) }

        subject
      end

    end

    context "builds a hash that" do

      it "has an entry containing the control value representation of the uri" do
        allow(HttpStub::Configurer::Request::ControllableValue).to(
          receive(:format).with(fixture.request.uri).and_return("uri as a string")
        )

        expect(subject).to include(uri: "uri as a string")
      end

      it "has an entry for the method option" do
        expect(subject).to include(method: fixture.request.http_method)
      end

      it "has an entry containing the string representation of the request headers" do
        allow(HttpStub::Configurer::Request::ControllableValue).to(
          receive(:format).with(fixture.request.headers).and_return("request headers as string")
        )

        expect(subject).to include(headers: "request headers as string")
      end

      it "has an entry containing the string representation of the request parameters" do
        allow(HttpStub::Configurer::Request::ControllableValue).to(
          receive(:format).with(fixture.request.parameters).and_return("request parameters as string")
        )

        expect(subject).to include(parameters: "request parameters as string")
      end

      it "has an entry containing the response payload" do
        allow(stub_response).to receive(:payload).and_return("response payload")

        expect(subject).to include(response: "response payload")
      end

      context "when a trigger is added" do

        include_context "triggers one stub"

        it "has a triggers entry containing the stub trigger payload" do
          expect(subject).to include(triggers: [ trigger_payload ])
        end

      end

      context "when many triggers are added" do

        include_context "triggers many stubs"

        it "has a triggers entry containing the stub trigger payloads" do
          expect(subject).to include(triggers: trigger_payloads)
        end

      end

      context "when no triggers are added" do

        it "has a triggers entry containing an empty hash" do
          expect(subject).to include(triggers: [])
        end

      end

    end

  end

  describe "#response_files" do

    subject { stub.response_files }

    context "when the response contains a file" do

      let(:response_file) { instance_double(HttpStub::Configurer::Request::StubResponseFile) }

      before(:example) { allow(stub_response).to receive(:file).and_return(response_file) }

      context "and the triggers contain files" do

        include_context "triggers many stubs"

        let(:triggers_files) do
          trigger_payloads.map { (1..3).map { instance_double(HttpStub::Configurer::Request::StubResponseFile) } }
        end

        it "returns the stub response's file and the triggers files" do
          expect(subject).to eql(([ response_file ] + triggers_files).flatten)
        end

      end

      context "and the triggers contain no files" do

        include_context "triggers many stubs"

        let(:triggers_files) { trigger_payloads.map { (1..3).map { [] } } }

        it "returns the stub response's file" do
          expect(subject).to eql([ response_file ])
        end

      end

    end

    context "when the response body does not contain a file" do

      before(:example) { allow(stub_response).to receive(:file).and_return(nil) }

      context "and the triggers contain files" do

        include_context "triggers many stubs"

        let(:triggers_files) do
          trigger_payloads.map { (1..3).map { instance_double(HttpStub::Configurer::Request::StubResponseFile) } }
        end

        it "returns the stub response's file and the triggers files" do
          expect(subject).to eql(triggers_files.flatten)
        end

      end

      context "and no triggers contain a file" do

        include_context "triggers many stubs"

        let(:triggers_files) { trigger_payloads.map { (1..3).map { [] } } }

        it "returns a empty array" do
          expect(subject).to eql([])
        end

      end

    end

  end

  describe "#to_s" do

    it "returns the request uri" do
      expect(stub.to_s).to eql(fixture.request.uri)
    end

  end

end
