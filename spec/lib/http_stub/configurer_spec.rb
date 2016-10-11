describe HttpStub::Configurer do

  class HttpStub::Configurer::TestableConfigurer
    include HttpStub::Configurer
  end

  let(:configurer_class) { HttpStub::Configurer::TestableConfigurer }
  let(:configurer)       { configurer_class.new }

  describe "::stub_server" do

    subject { configurer_class.stub_server }

    it "creates a server DSL" do
      expect(HttpStub::Configurer::DSL::Server).to receive(:new)

      subject
    end

    it "returns the created server DSL" do
      server = instance_double(HttpStub::Configurer::DSL::Server)
      allow(HttpStub::Configurer::DSL::Server).to receive(:new).and_return(server)

      expect(subject).to eql(server)
    end

    it "reuses the stub server in subsequent requests" do
      server = configurer_class.stub_server

      expect(subject).to be(server)
    end

  end

  describe "::initialize!" do

    subject { configurer_class.initialize! }

    before(:example) { allow(configurer_class.stub_server).to receive(:initialize!) }

    context "when included in a class with an on_initialize class method" do

      let(:configurer_class) do
        Class.new do
          include HttpStub::Configurer

          def self.on_initialize
            # Intentionally blank
          end
        end
      end

      context "and the class has not been initialized previously" do

        it "invokes the on_initialize method" do
          expect(configurer_class).to receive(:on_initialize)

          subject
        end

      end

      context "and the class has been initialized previously" do

        before(:example) { configurer_class.initialize! }

        it "does not re-invoke the on_initialize method" do
          expect(configurer_class).to_not receive(:on_initialize)

          subject
        end

      end

    end

    context "when included in a class without an on_initialize method" do

      let(:configurer_class) { Class.new { include HttpStub::Configurer } }

      it "executes without error" do
        expect { subject }.to_not raise_error
      end

    end

    it "initializes the stub server" do
      expect(configurer_class.stub_server).to receive(:initialize!)

      subject
    end

  end

  describe "#stub_server" do

    subject { configurer.stub_server }

    it "returns the same server as the class method" do
      expect(subject).to be(configurer_class.stub_server)
    end

  end

end
