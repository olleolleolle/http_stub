describe HttpStub::ServerDaemon do

  let(:server) { HttpStub::ServerDaemon.new(name: :example_server_daemon, port: 8002) }

  it_should_behave_like "a managed http server"

end
