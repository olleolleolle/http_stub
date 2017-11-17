describe HttpStub::Rake::ServerDaemonTasks do
  include_context "surpressed output"
  include Rake::DSL

  before(:context) do
    @server_name_in_rakefile = :example_server_daemon
    @port_in_rakefile        = 8001
    HttpStub::Rake::ServerDaemonTasks.new(
      name:         @server_name_in_rakefile,
      configurator: HttpStub::ConfiguratorFixture.create(port: @port_in_rakefile)
    )
  end

  describe "start task" do

    context "when invoked" do

      before(:context) { @exit_flag = system "rake #{@server_name_in_rakefile}:start > /dev/null" }

      after(:context) { system "rake #{@server_name_in_rakefile}:stop > /dev/null" }

      it "exits with a status code of 0" do
        expect(@exit_flag).to be(true)
      end

      it "starts a stub server that responds to stub requests" do
        response = HTTParty.get("http://localhost:#{@port_in_rakefile}/http_stub/stubs")

        expect(response.code).to eql(200)
      end

    end

  end

end
