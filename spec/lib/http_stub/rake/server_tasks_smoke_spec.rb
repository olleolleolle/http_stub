describe HttpStub::Rake::ServerTasks do
  include Rake::DSL

  before(:context) { HttpStub::Rake::ServerTasks.new(name: :test_server, port: 8003) }

  describe "start task" do

    context "when invoked" do

      before(:context) do
        @server_thread = Thread.new { Rake::Task["test_server:start:foreground"].invoke("--trace") }
        ::Wait.until!("http stub server started") { Net::HTTP.get_response("localhost", "/", 8003) }
      end

      after(:context) { @server_thread.kill }

      it "starts a stub server that responds to stub requests" do
        request = Net::HTTP::Post.new("/stubs")
        request.body = { "response" => { "status" => 302, "body" => "Some Body" } }.to_json

        response = Net::HTTP.new("localhost", 8003).start { |http| http.request(request) }

        expect(response.code).to eql("200")
      end

    end

  end

end
