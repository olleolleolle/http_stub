describe HttpStub::Configurer::Request::StubActivatorBuilder do

  let(:stub_fixture) { HttpStub::StubFixture.new }

  let(:response_defaults) { {} }
  let(:stub)              { instance_double(HttpStub::Configurer::Request::Stub) }
  let(:stub_builder)      { instance_double(HttpStub::Configurer::Request::StubBuilder, build: stub) }

  let(:builder) { HttpStub::Configurer::Request::StubActivatorBuilder.new(response_defaults) }

  before(:example) { allow(HttpStub::Configurer::Request::StubBuilder).to receive(:new).and_return(stub_builder) }

  describe "constructor" do

    subject { builder }

    it "creates a stub builder with the provided response defaults" do
      expect(HttpStub::Configurer::Request::StubBuilder).to receive(:new).with(response_defaults)

      subject
    end

  end

  describe "#match_requests" do

    let(:request_payload) { stub_fixture.request.dsl_payload }

    it "delegates to a stub builder" do
      expect(stub_builder).to receive(:match_requests).with(stub_fixture.request.uri, request_payload)

      builder.match_requests(stub_fixture.request.uri, request_payload)
    end

  end

  describe "#respond_with" do

    let(:response_payload) { stub_fixture.response.dsl_payload }

    it "delegates to a stub builder" do
      expect(stub_builder).to receive(:respond_with).with(response_payload)

      builder.respond_with(response_payload)
    end

  end

  describe "#trigger" do

    context "when one triggered stub is provided" do

      let(:trigger_builder) { instance_double(HttpStub::Configurer::Request::StubBuilder) }

      it "delegates to a stub builder" do
        expect(stub_builder).to receive(:trigger).with(trigger_builder)

        builder.trigger(trigger_builder)
      end

    end

    context "when many triggered stubs are provided" do

      let(:trigger_builders) { (1..3).map { instance_double(HttpStub::Configurer::Request::StubBuilder) } }

      it "delegates to a stub builder" do
        expect(stub_builder).to receive(:trigger).with(trigger_builders)

        builder.trigger(trigger_builders)
      end

    end

  end

  describe "#build" do

    let(:stub_activator) { instance_double(HttpStub::Configurer::Request::StubActivator) }

    subject { builder.build }

    before(:example) { allow(HttpStub::Configurer::Request::StubActivator).to receive(:new).and_return(stub_activator) }

    context "when a path on which the activator is activated is established" do

      let(:activation_uri) { "http://some/activation/uri" }

      before(:example) { builder.on(activation_uri) }

      it "creates a stub activator that includes the activation uri" do
        expect(HttpStub::Configurer::Request::StubActivator).to(
          receive(:new).with(hash_including(activation_uri: activation_uri))
        )

        subject
      end

      it "builds the stub" do
        expect(stub_builder).to receive(:build)

        subject
      end

      it "creates a stub activator that includes the built stub" do
        expect(HttpStub::Configurer::Request::StubActivator).to receive(:new).with(hash_including(stub: stub))

        subject
      end

      it "returns the created stub activator" do
        expect(subject).to eql(stub_activator)
      end

    end

  end

end
