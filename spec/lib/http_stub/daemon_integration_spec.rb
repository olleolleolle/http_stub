describe HttpStub::Daemon do

  let(:server) { HttpStub::Daemon.new(name: :example_daemon, port: 8002) }

  it_should_behave_like "a managed http server"

end
