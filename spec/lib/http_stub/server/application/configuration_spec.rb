describe HttpStub::Server::Application::Configuration do

  let(:configuration) { described_class.new(args) }

  describe "#settings" do

    subject { configuration.settings }

    context "when a configurer is provided" do

      let(:port)                      { 8888 }
      let(:session_identifier)        { { parameters: :some_session_parameter } }
      let(:cross_origin_support_flag) { true }
      let(:stub_server)               do
        instance_double(HttpStub::Configurer::DSL::Server, port: port, session_identifier: session_identifier)
      end
      let(:configurer)         { double(HttpStub::Configurer, stub_server: stub_server) }
      let(:args)               { { configurer: configurer } }

      before(:example) do
        allow(stub_server).to receive(:enabled?).with(:cross_origin_support).and_return(cross_origin_support_flag)
      end

      it "has the configurers port" do
        expect(subject).to include(port: port)
      end

      it "has the configurers session identifier" do
        expect(subject).to include(session_identifier: session_identifier)
      end

      it "has the configurers cross origin support flag" do
        expect(subject).to include(cross_origin_support: cross_origin_support_flag)
      end

    end

    context "when a configurer is not provided" do

      let(:port) { 8889 }
      let(:args) { { port: port } }

      it "has the provided port" do
        expect(subject).to include(port: port)
      end

      it "has a nil session identifier" do
        expect(subject).to include(session_identifier: nil)
      end

      it "has disabled cross origin support" do
        expect(subject).to include(cross_origin_support: false)
      end

    end

  end

end
