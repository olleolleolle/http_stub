describe HttpStub::Server::Daemon do

  describe "::log_dir" do

    before(:example) { @original_log_dir = HttpServerManager.log_dir }

    after(:example) { HttpServerManager.log_dir = @original_log_dir }

    it "establishes the HttpServerManager log_dir" do
      HttpStub::Server::Daemon.log_dir = "/some/log/dir"

      expect(HttpServerManager.log_dir).to eql("/some/log/dir")
    end

  end

  describe "::pid_dir" do

    before(:example) { @original_pid_dir = HttpServerManager.pid_dir }

    after(:example) { HttpServerManager.pid_dir = @original_pid_dir }

    it "establishes the HttpServerManager pid_dir" do
      HttpStub::Server::Daemon.pid_dir = "/some/pid/dir"

      expect(HttpServerManager.pid_dir).to eql("/some/pid/dir")
    end

  end

  describe "constructor" do

    let(:server_port)  { 8888 }
    let(:configurator) { Class.new { include HttpStub::Configurator } }

    let(:server_daemon) { HttpStub::Server::Daemon.new(name: :sample_server_daemon, configurator: configurator) }

    before(:example) { configurator.state.port = server_port }

    it "establishes the daemons host as localhost by default" do
      expect(server_daemon.host).to eql("localhost")
    end

    it "establishes the daemons port as the configured port" do
      expect(server_daemon.port).to eql(server_port)
    end

  end

end
