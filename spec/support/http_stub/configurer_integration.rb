shared_context "configurer integration" do
  include_context "server integration"

  let(:configurer_specification)           { {} }
  let(:effective_configurer_specification) do
    { class: HttpStub::EmptyConfigurer, initialize: true }.merge(configurer_specification)
  end

  let(:server_specification) { effective_configurer_specification.slice(:name, :port) }

  let(:configurer)  { effective_configurer_specification[:class] }
  let(:stub_server) { configurer.stub_server }

  let(:stub_registrator) { HttpStub::StubRegistrator.new(stub_server) }

  before(:example) do
    stub_server.host = server_host
    stub_server.port = server_port
    configurer.initialize! if effective_configurer_specification[:initialize]
  end

  after(:example) { stub_server.reset! }

end
