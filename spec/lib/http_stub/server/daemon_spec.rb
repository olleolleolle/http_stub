describe HttpStub::Server::Daemon do

  let(:server_port) { 8888 }

  let(:server_daemon) { create_daemon_without_configurer }

  before(:example) { allow(server_daemon.logger).to receive(:info) }

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

    context "when a configurer is provided" do

      let(:server_host) { "some_host" }
      let(:stub_server) { instance_double(HttpStub::Configurer::DSL::Server, host: server_host, port: server_port) }
      let(:configurer)  { double(HttpStub::Configurer, stub_server: stub_server) }

      let(:server_daemon) { create_daemon_with_configurer }

      it "establishes the daemons host as the configurers server host" do
        expect(server_daemon.host).to eql(server_host)
      end

      it "establishes the daemons port as the configurers server port" do
        expect(server_daemon.port).to eql(server_port)
      end

    end

    context "when a configurer is not provided" do

      let(:server_daemon) { create_daemon_without_configurer }

      it "defaults the daemons host to 'localhost'" do
        expect(server_daemon.host).to eql("localhost")
      end

      it "establishes the daemons port as the provided value" do
        expect(server_daemon.port).to eql(server_port)
      end

    end

  end

  describe "#start!" do

    before(:example) { allow(server_daemon).to receive(:running?).and_return(true) }

    context "when a configurer is provided" do

      let(:configurer) { double(HttpStub::Configurer).as_null_object }

      let(:server_daemon) { create_daemon_with_configurer }

      it "initializes the configurer" do
        expect(configurer).to receive(:initialize!)

        server_daemon.start!
      end

      it "logs that the server with the provided name has been initialized" do
        expect(server_daemon.logger).to receive(:info).with("sample_server_daemon initialized")

        server_daemon.start!
      end

    end

    context "when no configurer is provided" do

      let(:server_daemon) { create_daemon_without_configurer }

      it "does not log that the server has been initialized" do
        expect(server_daemon.logger).not_to receive(:info).with("sample_server_daemon initialized")

        server_daemon.start!
      end

    end

  end

  def create_daemon_with_configurer
    HttpStub::Server::Daemon.new(name: :sample_server_daemon, configurer: configurer)
  end

  def create_daemon_without_configurer
    HttpStub::Server::Daemon.new(name: :sample_server_daemon, port: server_port)
  end

end
