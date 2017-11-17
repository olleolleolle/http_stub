describe HttpStub::Configurator do

  let(:configurator_class) { Class.new { include HttpStub::Configurator } }
  let(:configurator)       { configurator_class.new }

  describe "::state" do

    subject { configurator_class.state }

    it "creates state for the configurator" do
      expect(HttpStub::Configurator::State).to receive(:new)

      subject
    end

    it "returns the created state" do
      state = HttpStub::Configurator::State.new
      allow(HttpStub::Configurator::State).to receive(:new).and_return(state)

      expect(subject).to eql(state)
    end

    it "reuses the state in subsequent requests" do
      expect(subject).to be(configurator_class.state)
    end

  end

  describe "::stub_server" do

    subject { configurator_class.stub_server }

    it "creates a server" do
      expect(HttpStub::Configurator::Server).to receive(:new)

      subject
    end

    it "returns the created server" do
      server = instance_double(HttpStub::Configurator::Server)
      allow(HttpStub::Configurator::Server).to receive(:new).and_return(server)

      expect(subject).to eql(server)
    end

    it "reuses the stub server in subsequent requests" do
      expect(subject).to be(configurator_class.stub_server)
    end

  end

  describe "::parts=" do

    class HttpStub::Configurator::TestablePart
      include HttpStub::Configurator::Part

      attr_reader :configurator_class

      def apply_to(configurator_class)
        @configurator_class = configurator_class
      end

    end

    let(:parts) { (1..3).map { HttpStub::Configurator::TestablePart.new } }

    subject do
      configurator_class.parts = { part_1: parts[0], part_2: parts[1], part_3: parts[2] }
    end

    it "allows each part to be accessed on the configurator by name" do
      subject

      parts_on_configurator = [ configurator.part_1, configurator.part_2, configurator.part_3 ]
      expect(parts_on_configurator).to eql(parts)
    end

    it "allows each part to be accessed on the configurator class by name" do
      subject

      parts_on_configurator_class = [ configurator_class.part_1, configurator_class.part_2, configurator_class.part_3 ]
      expect(parts_on_configurator_class).to eql(parts)
    end

    it "applies the parts to the configurator" do
      subject

      expect(parts.map(&:configurator_class)).to eql([ configurator_class ] * 3)
    end

  end

  describe "#state" do

    subject { configurator.state }

    it "returns the same state as the class method" do
      expect(subject).to be(configurator_class.state)
    end

  end

  describe "#stub_server" do

    subject { configurator.stub_server }

    it "returns the same server as the class method" do
      expect(subject).to be(configurator_class.stub_server)
    end

  end

end
