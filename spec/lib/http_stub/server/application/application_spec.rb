describe HttpStub::Server::Application::Application do
  include_context "http_stub rack application test"

  it "disables all standard HTTP security measures to allow stubs full control of responses" do
    expect(app.settings.protection).to eql(false)
  end

  it "disables cross origin support by default" do
    expect(app.settings.cross_origin_support).to eql(false)
  end

  describe "::configure" do

    let(:args)                { { some_argument_key: "some argument value" } }
    let(:configured_settings) { { setting_1: "value 1", setting_2: "value 2", setting_3: "value 3" } }
    let(:configuration)       do
      instance_double(HttpStub::Server::Application::Configuration, settings: configured_settings)
    end

    subject { described_class.configure(args) }

    before(:example) { allow(HttpStub::Server::Application::Configuration).to receive(:new).and_return(configuration) }

    it "creates application configuration encapsulating the arguments" do
      expect(HttpStub::Server::Application::Configuration).to receive(:new).with(args).and_return(configuration)

      subject
    end

    it "establishes the configured settings on the application" do
      subject

      configured_settings.each { |name, value| expect(described_class.settings.send(name)).to eql(value) }
    end

  end

  describe "session identifer" do

    context "when configured" do

      include_context "enabled session support"

      it "creates a request factory with the configuration" do
        expect(HttpStub::Server::Request::Factory).to receive(:new).with(session_identifier, anything, anything)

        issue_a_request
      end

    end

    context "when not configured" do

      it "creates a request factory with a nil configuration" do
        expect(HttpStub::Server::Request::Factory).to receive(:new).with(nil, anything, anything)

        issue_a_request
      end

    end

    def issue_a_request
      get "/application.css"
    end

  end

end
