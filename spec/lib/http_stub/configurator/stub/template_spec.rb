describe HttpStub::Configurator::Stub::Template do

  let(:parent_uri)             { "/some/parent/uri" }
  let(:parent_template)        do
    described_class.new.tap do |template|
      template.match_requests(uri: parent_uri)
      template.respond_with(body: "parent template body")
    end
  end
  let(:initial_request_method) { :put }
  let(:initial_block)          { lambda { |stub| stub.match_requests(method: initial_request_method) } }

  let(:template) { described_class.new }

  shared_context "mocked stub" do

    let(:templates_stub) { instance_double(HttpStub::Configurator::Stub::Stub) }

    before(:example) { allow(HttpStub::Configurator::Stub::Stub).to receive(:new).and_return(templates_stub) }

  end

  it "creates a stub to hold values established on the template" do
    allow(HttpStub::Configurator::Stub::Stub).to receive(:new)

    template
  end

  describe "#match_requests" do
    include_context "mocked stub"

    let(:request_matching_rules) { { uri: "/some/stub/uri", method: :get } }

    subject { template.match_requests(request_matching_rules) }

    it "delegates to the templates stub" do
      expect(templates_stub).to receive(:match_requests).with(request_matching_rules)

      subject
    end

  end

  describe "#schema" do
    include_context "mocked stub"

    let(:type)       { :some_schema_type }
    let(:definition) { "some schema definition" }

    subject { template.schema(type, definition) }

    it "delegates to the templates stub" do
      expect(templates_stub).to receive(:schema).with(type, definition)

      subject
    end

    it "returns the created schema" do
      schema = { schema: :some_schema }
      expect(templates_stub).to receive(:schema).and_return(schema)

      expect(subject).to eql(schema)
    end

  end

  describe "#respond_with" do
    include_context "mocked stub"

    let(:response_settings) { { status: 204 } }

    subject { template.respond_with(response_settings) }

    it "delegates to the templates stub" do
      expect(templates_stub).to receive(:respond_with).with(response_settings)

      subject
    end

  end

  describe "#trigger" do
    include_context "mocked stub"

    let(:trigger_settings) { { scenario: "some scenario name" } }

    subject { template.trigger(trigger_settings) }

    it "delegates to the templates stub" do
      expect(templates_stub).to receive(:trigger).with(trigger_settings)

      subject
    end

  end

  describe "#invoke" do
    include_context "mocked stub"

    let(:block_verifier) { double("BlockVerifier") }
    let(:block)          do
      lambda do |stub|
        @yielded_stub = stub
        block_verifier.verify
      end
    end

    let(:templates_stub) { HttpStub::Configurator::Stub::Stub.new }

    subject { template.invoke(&block) }

    it "invokes the block with the templates stub builder" do
      expect(block_verifier).to receive(:verify)

      subject

      expect(@yielded_stub).to eql(templates_stub)
    end

  end

  describe "#build_stub" do

    let(:stub_builder_template) { described_class.new(parent_template) }
    let(:response_overrides)    { { status: 201, body: "response overrides body" } }
    let(:block)                 do
      lambda do |stub|
        stub.match_requests(uri: "/some/block/uri")
        stub.respond_with(body: "block body")
      end
    end

    let(:template) { described_class.new(parent_template) }

    let(:built_stub_hash) { subject.to_hash }

    subject { template.build_stub }

    context "when a parent template had been provided" do

      it "creates a stub capable of containing values established in the parent template" do
        expect(built_stub_hash[:match_rules][:uri]).to eql(parent_uri)
      end

    end

    context "when an initial block had been provided" do

      let(:template) { described_class.new(&initial_block) }

      it "creates a stub capable of containing values established in the initial block" do
        expect(built_stub_hash[:match_rules][:method]).to eql(initial_request_method)
      end

    end

    context "when response overrides are provided upon building the stub" do

      subject { template.build_stub(response_overrides) }

      it "creates a stub containing the overrides" do
        expect(built_stub_hash[:response][:status]).to eql(201)
      end

      it "overrides any values initially established" do
        expect(built_stub_hash[:response][:body]).to eql("response overrides body")
      end

    end

    context "when a block is provided upon building the stub" do

      subject { template.build_stub(&block) }

      it "creates a stub that is modified by the block" do
        expect(built_stub_hash[:match_rules][:uri]).to eql("/some/block/uri")
      end

      it "overrides any values initially established" do
        expect(built_stub_hash[:response][:body]).to eql("block body")
      end

    end

    context "when both response overrides and a block are provided" do

      subject { template.build_stub(response_overrides, &block) }

      it "creates a stub containing response overrides" do
        expect(built_stub_hash[:response][:status]).to eql(201)
      end

      it "creates a stub that is modified by the block" do
        expect(built_stub_hash[:match_rules][:uri]).to eql("/some/block/uri")
      end

      it "creates a stub with values established in the block taking precedence over response overrides" do
        expect(built_stub_hash[:response][:body]).to eql("block body")
      end

    end

  end

end
