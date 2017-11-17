describe HttpStub::Rake::ServerTasks do
  include_context "surpressed output"
  include Rake::DSL

  let(:server_name)  { "test_server_#{SecureRandom.uuid}"}
  let(:port)         { HttpStub::Port.free_port }
  let(:configurator) { HttpStub::ConfiguratorFixture.create(port: port) }

  before(:example) { HttpStub::Rake::ServerTasks.new(name: server_name, configurator: configurator) }

  describe "start:foreground task" do

    let(:task) { Rake::Task["#{server_name}:start:foreground"] }

    context "when invoked" do

      before(:example) do
        Thread.new { task.invoke("--silent") }
        wait_until_server_has_started
      end

      after(:example) { wait_until_server_has_stopped }

      it "starts a stub server that responds to stub requests" do
        response = HTTParty.get("http://localhost:#{port}/http_stub/stubs")

        expect(response.code).to eql(200)
      end

      def wait_until_server_has_started
        ::Wait.until!(description: "http stub server #{server_name} started") do
          HTTParty.get("http://localhost:#{port}")
        end
      end

      def wait_until_server_has_stopped
        HttpStub::Server::Application::Application.stop!
        ::Wait.until_true!(description: "http stub server #{server_name} stopped") do
          HTTParty.get("http://localhost:#{port}", timeout: 1) && false rescue true
        end
      end

    end

  end

end
