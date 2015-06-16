describe HttpStub::Rake::ServerTasks do
  include Rake::DSL

  shared_context "verification of generated tasks" do

    before(:example) { HttpStub::Rake::ServerTasks.new(task_args) }

    describe "start:foreground task" do

      let(:task) { Rake::Task["#{task_args[:name]}:start:foreground"] }

      context "when invoked" do

        before(:example) do
          @server_thread = Thread.new { task.invoke("--trace") }
          wait_until_server_has_started
        end

        after(:example) do
          @server_thread.kill
          wait_until_server_has_stopped
        end

        it "starts a stub server that responds to stub requests" do
          request = Net::HTTP::Post.new("/stubs")
          request.body = { "uri" => "/", "response" => { "status" => 302, "body" => "Some Body" } }.to_json

          response = Net::HTTP.new("localhost", port).start { |http| http.request(request) }

          expect(response.code).to eql("200")
        end

        def wait_until_server_has_started
          ::Wait.until!("http stub server #{task_args[:name]} started") do
            Net::HTTP.get_response("localhost", "/", port)
          end
        end

        def wait_until_server_has_stopped
          ::Wait.until_false!("http stub server #{task_args[:name]} stopped") do
            Net::HTTP.get_response("localhost", "/", port) rescue false
          end
        end

      end

    end

  end

  context "when a configurer is provided" do

    let(:port) { 8004 }
    let(:configurer) do
      configurer = Class.new.tap do |configurer|
        configurer.send(:include, HttpStub::Configurer)
        configurer.stub_server.host = "localhost"
        configurer.stub_server.port = port
      end
    end
    let(:task_args) { { name: :test_server_with_configurer, configurer: configurer } }

    include_context "verification of generated tasks"

  end

  context "when a port is provided" do

    let(:port)      { 8003 }
    let(:task_args) { { name: :test_server_with_port, port: port } }

    include_context "verification of generated tasks"

  end

end
