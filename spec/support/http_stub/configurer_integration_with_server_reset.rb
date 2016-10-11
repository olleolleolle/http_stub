shared_context "configurer integration with server reset" do
  include_context "configurer integration"

  before(:example) do
    stub_server.host = server_host
    stub_server.port = server_port
  end

  after(:example) { stub_server.reset! }

end
