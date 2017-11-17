describe HttpStub::Server::Daemon do

  let(:server_name_in_rakefile) { :example_server_daemon }
  let(:port_in_rakefile)        { 8001 }

  let(:configurator) { HttpStub::ConfiguratorFixture.create(port: port_in_rakefile) }
  let(:server)       { HttpStub::Server::Daemon.new(name: server_name_in_rakefile, configurator: configurator) }

  it_behaves_like "a managed http server"

end
