describe HttpStub::ServerDaemon do

  let(:configurer) { nil }

  let(:server_daemon) { HttpStub::ServerDaemon.new(name: :sample_server_daemon, port: 8888, configurer: configurer) }

  before(:each) { server_daemon.logger.stub(:info) }

  describe ".log_dir" do

    before(:each) { @original_log_dir = HttpServerManager.log_dir }

    after(:each) { HttpServerManager.log_dir = @original_log_dir }

    it "should establish the HttpServerManager log_dir" do
      HttpStub::ServerDaemon.log_dir = "/some/log/dir"

      HttpServerManager.log_dir.should eql("/some/log/dir")
    end

  end

  describe ".pid_dir" do

    before(:each) { @original_pid_dir = HttpServerManager.pid_dir }

    after(:each) { HttpServerManager.pid_dir = @original_pid_dir }

    it "should establish the HttpServerManager pid_dir" do
      HttpStub::ServerDaemon.pid_dir = "/some/pid/dir"

      HttpServerManager.pid_dir.should eql("/some/pid/dir")
    end

  end

  describe "#start!" do

    before(:each) { server_daemon.stub(:running?).and_return(true) }

    context "when a configurer is provided" do

      let(:configurer) { double(HttpStub::Configurer).as_null_object }

      it "should initialize the configurer" do
        configurer.should_receive(:initialize!)

        server_daemon.start!
      end

      it "should log that the server with the provided name has been initialized" do
        server_daemon.logger.should_receive(:info).with("sample_server_daemon initialized")

        server_daemon.start!
      end

    end

    context "when no configurer is provided" do

      it "should not log that the server has been initialized" do
        server_daemon.logger.should_not_receive(:info).with("sample_server_daemon initialized")

        server_daemon.start!
      end

    end

  end

end
