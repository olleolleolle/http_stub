describe HttpStub::Rake::ServerDaemonTasks do
  include Rake::DSL

  before(:all) { HttpStub::Rake::ServerDaemonTasks.new(name: :example_server_daemon, port: 8002) }

  describe "start task" do

    context "when invoked" do

      before(:all) { @exit_flag = Rake::Task["example_server_daemon:start"].invoke("--trace") }

      after(:all) { Rake::Task["example_server_daemon:stop"].invoke("--trace") }

      it "should exit with a status code of 0" do
        @exit_flag.should be_true
      end

      it "should start a stub server that responds to stub requests" do
        request = Net::HTTP::Post.new("/stubs")
        request.body = { "response" => { "status" => 302, "body" => "Some Body" } }.to_json

        response = Net::HTTP.new("localhost", 8002).start { |http| http.request(request) }

        response.code.should eql("200")
      end

    end

  end

end
