describe HttpStub::Configurer::Request::Stub do

  let(:fixture)          { HttpStub::StubFixture.new }
  let(:stub_response)    { instance_double(HttpStub::Configurer::Request::StubResponse) }
  let(:stub_triggers)    { instance_double(HttpStub::Configurer::Request::Triggers) }

  let(:stub) { HttpStub::Configurer::Request::Stub.new(fixture.configurer_payload) }

  before(:example) do
    allow(HttpStub::Configurer::Request::StubResponse).to receive(:new).and_return(stub_response)
    allow(HttpStub::Configurer::Request::Triggers).to receive(:new).and_return(stub_triggers)
  end

  describe "#payload" do

    subject { stub.payload }

    before(:example) do
      allow(HttpStub::Configurer::Request::ControllableValue).to receive(:format)
      allow(stub_response).to receive(:payload)
      allow(stub_triggers).to receive(:payload)
    end

    context "when request headers" do

      context "are provided" do

        it "formats the headers into control values" do
          expect(HttpStub::Configurer::Request::ControllableValue).to receive(:format).with(fixture.request.headers)

          subject
        end

      end

      context "are not provided" do

        before(:example) { fixture.request.headers = nil }

        it "formats an empty header hash" do
          expect(HttpStub::Configurer::Request::ControllableValue).to receive(:format).with({})

          subject
        end

      end

    end

    context "when request parameters" do

      context "are provided" do

        it "formats the request parameters into control values" do
          expect(HttpStub::Configurer::Request::ControllableValue).to receive(:format).with(fixture.request.parameters)

          subject
        end

      end

      context "are not provided" do

        before(:example) { fixture.request.parameters = nil }

        it "formats an empty parameter hash" do
          expect(HttpStub::Configurer::Request::ControllableValue).to receive(:format).with({})

          subject
        end

      end

    end

    context "when a request body" do

      context "is provided" do

        it "formats the request body into a control value" do
          expect(HttpStub::Configurer::Request::ControllableValue).to receive(:format).with(fixture.request.body)

          subject
        end

      end

      context "is not provided" do

        before(:example) { fixture.request.body = nil }

        it "formats an empty parameter hash" do
          expect(HttpStub::Configurer::Request::ControllableValue).to receive(:format).with({})

          subject
        end

      end

    end

    it "creates a stub response with the provided response options" do
      expect(HttpStub::Configurer::Request::StubResponse).to(
        receive(:new).with(anything, fixture.configurer_payload[:response]).and_return(stub_response)
      )

      subject
    end

    it "creates stub triggers with the provided triggers options" do
      expect(HttpStub::Configurer::Request::Triggers).to(
        receive(:new).with(fixture.configurer_payload[:triggers]).and_return(stub_triggers)
      )

      subject
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

      it "has an entry containing the triggers payload" do
        allow(stub_triggers).to receive(:payload).and_return("triggers payload")

        expect(subject).to include(triggers: "triggers payload")
      end

    end

  end

  describe "#response_files" do

    let(:stub_response_file)      { nil }
    let(:triggers_response_files) { [] }

    subject { stub.response_files }

    before(:example) do
      allow(stub_response).to receive(:file).and_return(stub_response_file)
      allow(stub_triggers).to receive(:response_files).and_return(triggers_response_files)
    end

    context "when the response contains a file" do

      let(:stub_response_file) { instance_double(HttpStub::Configurer::Request::StubResponseFile) }

      let(:triggers_response_files) { [] }

      it "includes the stub response's file" do
        expect(subject).to include(stub_response_file)
      end

    end

    context "when the triggers contain files" do

      let(:triggers_response_files) do
        (1..3).map { instance_double(HttpStub::Configurer::Request::StubResponseFile) }
      end

      it "includes the triggers files" do
        expect(subject).to include(*triggers_response_files)
      end

    end

    context "when both the response and triggers contain files" do

      let(:stub_response_file)      { instance_double(HttpStub::Configurer::Request::StubResponseFile) }
      let(:triggers_response_files) do
        (1..3).map { instance_double(HttpStub::Configurer::Request::StubResponseFile) }
      end

      it "is all the files" do
        expect(subject).to eql(([ stub_response_file ] + triggers_response_files).flatten)
      end

    end

    context "when neither the response or triggers contain files" do

      it "returns an empty array" do
        expect(subject).to eql([])
      end

    end

  end

  describe "#to_s" do

    it "returns the request uri" do
      expect(stub.to_s).to eql(fixture.request.uri)
    end

  end

end
