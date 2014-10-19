describe HttpStub::Configurer::Server::DSL do

  let(:server_facade) { instance_double(HttpStub::Configurer::Server::Facade) }

  let(:dsl) { HttpStub::Configurer::Server::DSL.new(server_facade) }

  describe "#has_started!" do

    it "informs the facade to freeze the initial state of the server" do
      expect(server_facade).to receive(:remember_state)

      dsl.has_started!
    end

  end

  describe "#build_stub" do

    let(:stub_payload_builder) { instance_double(HttpStub::Configurer::Request::StubPayloadBuilder) }

    before(:example) do
      allow(HttpStub::Configurer::Request::StubPayloadBuilder).to receive(:new).and_return(stub_payload_builder)
    end

    it "creates a stub payload builder" do
      expect(HttpStub::Configurer::Request::StubPayloadBuilder).to receive(:new)

      dsl.build_stub
    end

    context "when a block is provided" do

      let(:block) { lambda { |_stub| "some block" } }

      subject { dsl.build_stub(&block) }

      it "yields the created builder to the provided block" do
        expect(block).to receive(:call).with(stub_payload_builder)

        subject
      end

      it "returns the created builder" do
        expect(subject).to eql(stub_payload_builder)
      end

    end

    context "when a block is not provided" do

      subject { dsl.build_stub }

      it "returns the built stub" do
        expect(subject).to eql(stub_payload_builder)
      end

    end

  end

  describe "#add_stub!" do

    let(:stub_payload)         { { stub_payload_key: "stub payload value" } }
    let(:stub_payload_builder) do
      instance_double(HttpStub::Configurer::Request::StubPayloadBuilder, build: stub_payload)
    end
    let(:stub_request)         { instance_double(HttpStub::Configurer::Request::Stub) }

    before(:example) do
      allow(HttpStub::Configurer::Request::Stub).to receive(:new).and_return(stub_request)
      allow(server_facade).to receive(:stub_response)
    end

    shared_examples_for "adding a stub payload" do

      it "builds the stub payload" do
        expect(stub_payload_builder).to receive(:build).and_return(stub_payload)

        subject
      end

      it "creates a stub request with the built payload" do
        expect(HttpStub::Configurer::Request::Stub).to receive(:new).with(stub_payload).and_return(stub_request)

        subject
      end

      it "informs the server facade to stub the response" do
        expect(server_facade).to receive(:stub_response).with(stub_request)

        subject
      end

    end

    context "when a stub payload builder is provided" do

      subject { dsl.add_stub!(stub_payload_builder) }

      it_behaves_like "adding a stub payload"

    end

    context "when a stub payload builder is not provided" do

      let(:block) { lambda { |_stub| "some block" } }

      before(:example) do
        allow(HttpStub::Configurer::Request::StubPayloadBuilder).to receive(:new).and_return(stub_payload_builder)
      end

      subject { dsl.add_stub!(&block) }

      it "creates a stub payload builder" do
        expect(HttpStub::Configurer::Request::StubPayloadBuilder).to receive(:new)

        subject
      end

      it "yields the created builder to the provided block" do
        expect(block).to receive(:call).with(stub_payload_builder)

        subject
      end

      it_behaves_like "adding a stub payload"

    end

  end

  describe "#add_activator!" do

    let(:stub_activator_payload)         { { activator_payload_key: "activator payload value" } }
    let(:stub_activator_payload_builder) do
      instance_double(HttpStub::Configurer::Request::StubActivatorPayloadBuilder, build: stub_activator_payload)
    end
    let(:stub_activator_request)         { instance_double(HttpStub::Configurer::Request::StubActivator) }

    before(:example) do
      allow(HttpStub::Configurer::Request::StubActivator).to receive(:new).and_return(stub_activator_request)
      allow(server_facade).to receive(:stub_activator)
    end

    let(:block) { lambda { |_activator| "some block" } }

    before(:example) do
      allow(HttpStub::Configurer::Request::StubActivatorPayloadBuilder).to(
        receive(:new).and_return(stub_activator_payload_builder)
      )
    end

    subject { dsl.add_activator!(&block) }

    it "creates a stub activator payload builder" do
      expect(HttpStub::Configurer::Request::StubActivatorPayloadBuilder).to receive(:new)

      subject
    end

    it "yields the created builder to the provided block" do
      expect(block).to receive(:call).with(stub_activator_payload_builder)

      subject
    end

    it "builds the stub activator payload" do
      expect(stub_activator_payload_builder).to receive(:build).and_return(stub_activator_payload)

      subject
    end

    it "creates a stub activator request with the built payload" do
      expect(HttpStub::Configurer::Request::StubActivator).to(
        receive(:new).with(stub_activator_payload).and_return(stub_activator_request)
      )

      subject
    end

    it "informs the server facade to submit the stub activator request" do
      expect(server_facade).to receive(:stub_activator).with(stub_activator_request)

      subject
    end

  end

  describe "#activate!" do

    let(:uri) { "/some/activation/uri" }

    it "delegates to the server facade" do
      expect(server_facade).to receive(:activate).with(uri)

      dsl.activate!(uri)
    end

  end

  describe "#reset!" do

    it "informs the server facade to restore the servers initial state" do
      expect(server_facade).to receive(:recall_state)

      dsl.reset!
    end

  end

  describe "#clear_stubs!" do

    it "delegates to the server facade" do
      expect(server_facade).to receive(:clear_stubs)

      dsl.clear_stubs!
    end

  end

  describe "#clear_activators!" do

    it "delegates to the server facade" do
      expect(server_facade).to receive(:clear_activators)

      dsl.clear_activators!
    end

  end

end
