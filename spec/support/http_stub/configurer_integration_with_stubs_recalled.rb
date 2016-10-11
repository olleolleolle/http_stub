shared_context "configurer integration with stubs recalled" do
  include_context "configurer integration"

  before(:context) do
    stub_server.host = server_host
    stub_server.port = server_port
    configurer.initialize!
  end

  after(:example) { stub_server.recall_stubs! }

end
