shared_context "server integration" do
  include Rack::Utils
  include HtmlHelpers

  let(:configurator) { HttpStub::Examples::ConfiguratorWithTrivialStubs }

  let(:server_driver) { HttpStub::Server::Driver.find_or_create(configurator) }
  let(:server_host)   { server_driver.host }
  let(:server_port)   { server_driver.port }
  let(:server_uri)    { server_driver.uri }
  let(:client)        { server_driver.client }

  before(:example) { server_driver.start! }

  after(:example) { client.reset! }

  def transactional_session_id
    "http_stub_transactional"
  end

end
