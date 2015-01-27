describe HttpStub::Configurer::Request::StubActivatorPayloadBuilder do

  include_context "stub payload builder arguments"

  let(:response_defaults) { {} }
  let(:stub_payload)      { { "stub_payload_key" => "stub payload value" } }
  let(:stub_builder)      { instance_double(HttpStub::Configurer::Request::StubPayloadBuilder, build: stub_payload) }

  let(:builder) { HttpStub::Configurer::Request::StubActivatorPayloadBuilder.new(response_defaults) }

  before(:example) do
    allow(HttpStub::Configurer::Request::StubPayloadBuilder).to receive(:new).and_return(stub_builder)
  end

  describe "constructor" do

    subject { builder }

    it "creates a stub payload builder with the provided response defaults" do
      expect(HttpStub::Configurer::Request::StubPayloadBuilder).to receive(:new).with(response_defaults)

      subject
    end

  end

  describe "#match_requests" do

    it "delegates to a stub payload builder" do
      expect(stub_builder).to receive(:match_requests).with(uri, request_options)

      builder.match_requests(uri, request_options)
    end

  end

  describe "#respond_with" do

    it "delegates to a stub payload builder" do
      expect(stub_builder).to receive(:respond_with).with(response_options)

      builder.respond_with(response_options)
    end

  end

  describe "#trigger" do

    context "when one triggered stub is provided" do

      let(:trigger_builder) { instance_double(HttpStub::Configurer::Request::StubPayloadBuilder) }

      it "delegates to a stub payload builder" do
        expect(stub_builder).to receive(:trigger).with(trigger_builder)

        builder.trigger(trigger_builder)
      end

    end

    context "when many triggered stubs are provided" do

      let(:trigger_builders) { (1..3).map { instance_double(HttpStub::Configurer::Request::StubPayloadBuilder) } }

      it "delegates to a stub payload builder" do
        expect(stub_builder).to receive(:trigger).with(trigger_builders)

        builder.trigger(trigger_builders)
      end

    end

  end

  describe "#build" do

    subject { builder.build }

    context "when a path on which the activator is activated is established" do

      let(:activation_uri) { "http://some/activation/uri" }

      before(:example) { builder.on(activation_uri) }

      it "returns a payload that includes the activation uri" do
        expect(subject).to include(activation_uri: activation_uri)
      end

      it "builds a stub payload" do
        expect(stub_builder).to receive(:build)

        subject
      end

      it "returns a payload that includes the stub payload" do
        expect(subject).to include(stub_payload)
      end

    end

  end

end
