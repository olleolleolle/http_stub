describe HttpStub::ServerDaemon do

  let(:configurer) { nil }

  let(:server_daemon) { HttpStub::ServerDaemon.new(name: :sample_server_daemon, port: 8888, configurer: configurer) }

  before(:example) { allow(server_daemon.logger).to receive(:info) }

  describe ".log_dir" do

    before(:example) { @original_log_dir = HttpServerManager.log_dir }

    after(:example) { HttpServerManager.log_dir = @original_log_dir }

    it "establishes the HttpServerManager log_dir" do
      HttpStub::ServerDaemon.log_dir = "/some/log/dir"

      expect(HttpServerManager.log_dir).to eql("/some/log/dir")
    end

  end

  describe ".pid_dir" do

    before(:example) { @original_pid_dir = HttpServerManager.pid_dir }

    after(:example) { HttpServerManager.pid_dir = @original_pid_dir }

    it "establishes the HttpServerManager pid_dir" do
      HttpStub::ServerDaemon.pid_dir = "/some/pid/dir"

      expect(HttpServerManager.pid_dir).to eql("/some/pid/dir")
    end

  end

  describe "#start!" do

    before(:example) { allow(server_daemon).to receive(:running?).and_return(true) }

    context "when a configurer is provided" do

      let(:configurer) { double(HttpStub::Configurer).as_null_object }

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

      it "does not log that the server has been initialized" do
        expect(server_daemon.logger).not_to receive(:info).with("sample_server_daemon initialized")

        server_daemon.start!
      end

    end

  end

end
