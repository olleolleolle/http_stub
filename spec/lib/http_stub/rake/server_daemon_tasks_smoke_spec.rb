describe HttpStub::Rake::ServerDaemonTasks do
  include Rake::DSL

  before(:context) { HttpStub::Rake::ServerDaemonTasks.new(name: :example_server_daemon, port: 8002) }

  describe "start task" do

    context "when invoked" do

      before(:context) { @exit_flag = Rake::Task["example_server_daemon:start"].invoke("--trace") }

      after(:context) { Rake::Task["example_server_daemon:stop"].invoke("--trace") }

      it "exits with a status code of 0" do
        expect(@exit_flag).to be_truthy
      end

      it "starts a stub server that responds to stub requests" do
        request = Net::HTTP::Post.new("/stubs")
        request.body = { "response" => { "status" => 302, "body" => "Some Body" } }.to_json

        response = Net::HTTP.new("localhost", 8002).start { |http| http.request(request) }

        expect(response.code).to eql("200")
      end

    end

  end

end
