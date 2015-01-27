describe HttpStub::Configurer::Server::DSL do

  let(:server_facade) { instance_double(HttpStub::Configurer::Server::Facade) }

  let(:dsl) { HttpStub::Configurer::Server::DSL.new(server_facade) }

  describe "#has_started!" do

    it "informs the facade that the server has started" do
      expect(server_facade).to receive(:server_has_started)

      dsl.has_started!
    end

  end

  describe "#build_stub" do

    let(:stub_payload_builder) { instance_double(HttpStub::Configurer::Request::StubPayloadBuilder) }

    before(:example) do
      allow(HttpStub::Configurer::Request::StubPayloadBuilder).to receive(:new).and_return(stub_payload_builder)
    end

    subject { dsl.build_stub }

    context "when response defaults have been established" do

      let(:response_defaults) { { key: "value" } }

      before(:example) { dsl.response_defaults = { key: "value" } }

      it "creates a stub payload builder containing the response defaults" do
        expect(HttpStub::Configurer::Request::StubPayloadBuilder).to receive(:new).with(response_defaults)

        subject
      end

    end

    context "when no response defaults have been established" do

      it "creates a stub payload builder with empty response defaults" do
        expect(HttpStub::Configurer::Request::StubPayloadBuilder).to receive(:new).with({})

        subject
      end

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

      it "informs the server facade of the stub request" do
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

  describe "#add_stubs!" do

    context "when multiple stub payload builders are provided" do

      let(:stub_payloads)         { (1..3).map { |i| { "stub_payload_key_#{i}" => "stub payload value #{i}" } } }
      let(:stub_payload_builders) do
        stub_payloads.map do |payload|
          instance_double(HttpStub::Configurer::Request::StubPayloadBuilder, build: payload)
        end
      end
      let(:stub_requests)         do
        (1..stub_payloads.length).map { instance_double(HttpStub::Configurer::Request::Stub) }
      end

      subject { dsl.add_stubs!(stub_payload_builders) }

      before(:example) do
        allow(HttpStub::Configurer::Request::Stub).to receive(:new).and_return(*stub_requests)
        allow(server_facade).to receive(:stub_response)
      end

      it "builds the each stub payload" do
        stub_payload_builders.zip(stub_payloads).each do |stub_payload_builder, stub_payload|
          expect(stub_payload_builder).to receive(:build).and_return(stub_payload)
        end

        subject
      end

      it "creates a stub request for each built payload" do
        stub_payloads.zip(stub_requests).each do |stub_payload, stub_request|
          expect(HttpStub::Configurer::Request::Stub).to receive(:new).with(stub_payload).and_return(stub_request)
        end

        subject
      end

      it "informs the server facade of each stub request" do
        stub_requests.each { |stub_request| expect(server_facade).to receive(:stub_response).with(stub_request) }

        subject
      end

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

    context "when response defaults have been established" do

    end

    context "when no response defaults have been established" do

    end

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

  describe "#remember_stubs" do

    it "delegates to the server facade" do
      expect(server_facade).to receive(:remember_stubs)

      dsl.remember_stubs
    end

  end

  describe "#recall_stubs!" do

    it "delegates to the server facade" do
      expect(server_facade).to receive(:recall_stubs)

      dsl.recall_stubs!
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
