describe HttpStub::Server::Application::Application do
  include_context "http_stub rack application test"

  describe "::configure" do

    let(:configured_settings) { { setting_1: "value 1", setting_2: "value 2", setting_3: "value 3" } }

    before(:example) { allow(configurator.state).to receive(:application_settings).and_return(configured_settings) }

    subject { described_class.configure(configurator) }

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

  describe "the memory" do

    let(:server_memory) { instance_double(HttpStub::Server::Memory::Memory).as_null_object }

    it "is created with the configured state" do
      expect(HttpStub::Server::Memory::Memory).to receive(:new).with(configurator.state).and_return(server_memory)

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
