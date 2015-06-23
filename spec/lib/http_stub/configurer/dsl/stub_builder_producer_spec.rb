describe HttpStub::Configurer::DSL::StubBuilderProducer do

  class HttpStub::Configurer::DSL::TestableStubBuilderProducer
    include HttpStub::Configurer::DSL::StubBuilderProducer

    def initialize(response_defaults)
      @response_defaults = response_defaults
      @builders = []
    end

    def add_stub!(builder)
      @builders << builder
    end

  end

  let(:response_defaults) { { default_key: "default value" } }

  let(:producer) { HttpStub::Configurer::DSL::TestableStubBuilderProducer.new(response_defaults) }

  describe "#build_stub" do

    let(:stub_builder) { instance_double(HttpStub::Configurer::DSL::StubBuilder) }

    before(:example) { allow(HttpStub::Configurer::DSL::StubBuilder).to receive(:new).and_return(stub_builder) }

    subject { producer.build_stub }

    it "creates a stub builder containing the producers response defaults" do
      expect(HttpStub::Configurer::DSL::StubBuilder).to receive(:new).with(response_defaults)

      subject
    end

    context "when a block is provided" do

      let(:block) { lambda { |_stub_builder| "some block" } }

      subject { producer.build_stub(&block) }

      before(:example) { allow(stub_builder).to receive(:invoke) }

      it "requests the stub builder invoke block" do
        expect(stub_builder).to receive(:invoke).and_yield(block)

        subject
      end

      it "returns the stub builder" do
        expect(subject).to eql(stub_builder)
      end

    end

    context "when a block is not provided" do

      subject { producer.build_stub }

      it "returns the stub builder" do
        expect(subject).to eql(stub_builder)
      end

    end

  end

  describe "#add_stubs!" do

    context "when multiple stub builders are provided" do

      let(:stub_builders) { (1..3).map { instance_double(HttpStub::Configurer::DSL::StubBuilder) } }

      subject { producer.add_stubs!(stub_builders) }

      it "adds each stub to the producer" do
        stub_builders.each { |stub_builder| expect(producer).to receive(:add_stub!).with(stub_builder) }

        subject
      end

    end

  end

end
