describe HttpStub::Configurer::DSL::EndpointTemplate do

  let(:server)                { instance_double(HttpStub::Configurer::DSL::Server) }
  let(:response_defaults)     { {} }
  let(:template_stub_builder) { instance_double(HttpStub::Configurer::DSL::StubBuilder) }

  let(:endpoint_template) { HttpStub::Configurer::DSL::EndpointTemplate.new(server) }

  before(:example) do
    allow(HttpStub::Configurer::DSL::StubBuilder).to receive(:new).and_return(template_stub_builder)
  end

  it "creates a stub builder to hold the templated default values" do
    expect(HttpStub::Configurer::DSL::StubBuilder).to receive(:new).with(no_args)

    endpoint_template
  end

  describe "#match_requests" do

    let(:args) { { key: :value } }

    subject { endpoint_template.match_requests(args) }

    it "delegates to the templates stub builder" do
      expect(template_stub_builder).to receive(:match_requests).with(args)

      subject
    end

  end

  describe "#schema" do

    let(:type)       { :some_type }
    let(:definition) { { key: :value } }

    subject { endpoint_template.schema(type, definition) }

    it "delegates to the templates stub builder" do
      expect(template_stub_builder).to receive(:schema).with(type, definition)

      subject
    end

  end

  describe "#respond_with" do

    let(:args) { { status: 204 } }

    subject { endpoint_template.respond_with(args) }

    it "delegates to the templates stub builder" do
      expect(template_stub_builder).to receive(:respond_with).with(args)

      subject
    end

  end

  describe "#trigger" do

    let(:trigger) { instance_double(HttpStub::Configurer::DSL::StubBuilder) }

    subject { endpoint_template.trigger(trigger) }

    it "delegates to the templates stub builder" do
      expect(template_stub_builder).to receive(:trigger).with(trigger)

      subject
    end

  end

  describe "#invoke" do

    let(:block_verifier) { double("BlockVerifier") }
    let(:block)          { lambda { block_verifier.verify } }

    subject { endpoint_template.invoke(&block) }

    it "delegates to the templates stub builder" do
      expect(template_stub_builder).to receive(:invoke).and_yield
      expect(block_verifier).to receive(:verify)

      subject
    end

  end

  shared_examples_for "an endpoint template method composing a stub" do

    it "merges the added stub with the default stub builder" do
      expect(stub_builder).to receive(:merge!).with(template_stub_builder)

      subject_without_overrides_and_block
    end

    context "when response overrides are provided" do

      let(:response_overrides) { { status: 302 } }

      subject { subject_with_response_overrides(response_overrides) }

      it "informs the stub builder to respond with the response overrides" do
        expect(stub_builder).to receive(:respond_with).with(response_overrides)

        subject
      end

    end

    context "when response overrides are not provided" do

      subject { subject_without_overrides_and_block }

      it "does not change the stub builder by requesting it respond with an empty hash" do
        expect(stub_builder).to receive(:respond_with).with({})

        subject
      end

    end

    it "merges the response defaults before applying the response overrides" do
      expect(stub_builder).to receive(:merge!).ordered
      expect(stub_builder).to receive(:respond_with).ordered

      subject_without_overrides_and_block
    end

    context "when a block is provided" do

      let(:block_verifier)     { double("BlockVerifier") }
      let(:block)              { lambda { block_verifier.verify } }

      subject { subject_with_block(&block) }

      it "requests the added stub builder invoke the provided block" do
        expect(stub_builder).to receive(:invoke).and_yield
        expect(block_verifier).to receive(:verify)

        subject
      end

      it "applies the response overrides before invoking the provided block" do
        expect(stub_builder).to receive(:respond_with).ordered
        expect(stub_builder).to receive(:invoke).ordered

        subject
      end

    end

    context "when a block is not provided" do

      subject { subject_without_overrides_and_block }

      it "does not requests the added stub builder invoke a block" do
        expect(stub_builder).not_to receive(:invoke)

        subject
      end

    end

  end

  describe "#build_stub" do

    let(:stub_builder) { instance_double(HttpStub::Configurer::DSL::StubBuilder).as_null_object }

    before(:example) { allow(server).to receive(:build_stub).and_yield(stub_builder) }

    def subject_without_overrides_and_block
      endpoint_template.build_stub
    end

    def subject_with_response_overrides(overrides)
      endpoint_template.build_stub(overrides)
    end

    def subject_with_block(&block)
      endpoint_template.build_stub(&block)
    end

    it "builds a stub on the server" do
      expect(server).to receive(:build_stub)

      subject_without_overrides_and_block
    end

    it_behaves_like "an endpoint template method composing a stub"

  end

  describe "#add_stub!" do

    let(:stub_builder) { instance_double(HttpStub::Configurer::DSL::StubBuilder).as_null_object }

    before(:example) { allow(server).to receive(:add_stub!).and_yield(stub_builder) }

    def subject_without_overrides_and_block
      endpoint_template.add_stub!
    end

    def subject_with_response_overrides(overrides)
      endpoint_template.add_stub!(overrides)
    end

    def subject_with_block(&block)
      endpoint_template.add_stub!(&block)
    end

    it "builds a stub on the server" do
      expect(server).to receive(:add_stub!)

      subject_without_overrides_and_block
    end

    it_behaves_like "an endpoint template method composing a stub"

  end

  describe "#add_scenario!" do

    let(:name)         { "some_scenario_name" }
    let(:stub_builder) { instance_double(HttpStub::Configurer::DSL::StubBuilder).as_null_object }

    before(:example) { allow(server).to receive(:add_scenario_with_one_stub!).and_yield(stub_builder) }

    def subject_without_overrides_and_block
      endpoint_template.add_scenario!(name)
    end

    def subject_with_response_overrides(overrides)
      endpoint_template.add_scenario!(name, overrides)
    end

    def subject_with_block(&block)
      endpoint_template.add_scenario!(name, &block)
    end

    it "adds a one stub scenario to the server" do
      expect(server).to receive(:add_scenario_with_one_stub!).with(name)

      subject_without_overrides_and_block
    end

    it_behaves_like "an endpoint template method composing a stub"

  end

end
