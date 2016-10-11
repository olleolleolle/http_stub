describe HttpStub::Server::Application::Application do
  include_context "http_stub rack application test"

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

  it "disables all standard HTTP security measures to allow stubs full control of responses" do
    expect(app.settings.protection).to eql(false)
  end

  it "disables cross origin support by default" do
    expect(app.settings.cross_origin_support).to eql(false)
  end

  describe "the session configuration" do

    let(:session_configuration) { instance_double(HttpStub::Server::Session::Configuration).as_null_object }

    context "when a session identifier is set" do

      include_context "enabled session support"

      it "is created on startup with the session identifier"  do
        expect(HttpStub::Server::Session::Configuration).to receive(:new).with(session_identifier)

        app
      end

    end

    context "when a session identifier is not configured" do

      it "is created on startup with a nil session identifier"  do
        expect(HttpStub::Server::Session::Configuration).to receive(:new).with(nil)

        app
      end

    end

    it "is reused on all requests" do
      expect(HttpStub::Server::Session::Configuration).to receive(:new).once

      issue_a_request
      issue_a_request
    end

  end

  describe "the memory" do

    let(:server_memory) { instance_double(HttpStub::Server::Memory::Memory).as_null_object }

    it "is created on startup" do
      expect(HttpStub::Server::Memory::Memory).to receive(:new).and_return(server_memory)

      app
    end

    it "is reused on all requests" do
      expect(HttpStub::Server::Memory::Memory).to receive(:new).once.and_return(server_memory)

      issue_a_request
      issue_a_request
    end

  end

  def issue_a_request
    get "/application.css"
  end

end
