describe HttpStub::Configurer::Request::StubBuilderProducer do

  class HttpStub::Configurer::Request::TestableStubBuilderProducer
    include HttpStub::Configurer::Request::StubBuilderProducer

    def initialize(response_defaults)
      @response_defaults = response_defaults
      @builders = []
    end

    def add_stub!(builder)
      @builders << builder
    end

  end

  let(:response_defaults) { { default_key: "default value" } }

  let(:producer) { HttpStub::Configurer::Request::TestableStubBuilderProducer.new(response_defaults) }

  describe "#build_stub" do

    let(:stub_builder) { instance_double(HttpStub::Configurer::Request::StubBuilder) }

    before(:example) { allow(HttpStub::Configurer::Request::StubBuilder).to receive(:new).and_return(stub_builder) }

    subject { producer.build_stub }

    it "creates a stub builder containing the producers response defaults" do
      expect(HttpStub::Configurer::Request::StubBuilder).to receive(:new).with(response_defaults)

      subject
    end

    context "when a block is provided" do

      context "that declares a stub builder parameter" do

        let(:block) { lambda { |_stub_builder| "some block" } }

        subject { producer.build_stub(&block) }

        it "yields the created builder to the provided block" do
          expect(block).to receive(:call).with(stub_builder)

          subject
        end

        it "returns the created builder" do
          expect(subject).to eql(stub_builder)
        end

      end

      context "that has no parameters" do

        subject { producer.build_stub { match_requests("/some/request/uri") } }

        before(:example) { allow(stub_builder).to receive(:match_requests) }

        it "executes the block in the context of the builder" do
          expect(stub_builder).to receive(:match_requests).with("/some/request/uri")

          subject
        end

        it "returns the created builder" do
          expect(subject).to eql(stub_builder)
        end

      end

    end

    context "when a block is not provided" do

      subject { producer.build_stub }

      it "returns the built stub" do
        expect(subject).to eql(stub_builder)
      end

    end

  end

  describe "#add_stubs!" do

    context "when multiple stub builders are provided" do

      let(:stub_builders) { (1..3).map { instance_double(HttpStub::Configurer::Request::StubBuilder) } }

      subject { producer.add_stubs!(stub_builders) }

      it "adds each stub to the producer" do
        stub_builders.each { |stub_builder| expect(producer).to receive(:add_stub!).with(stub_builder) }

        subject
      end

    end

  end

end
