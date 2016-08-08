shared_context "server integration" do
  include Rack::Utils
  include HtmlHelpers

  before(:context) do
    @server_pid = Process.spawn("rake #{server_name}:start:foreground --trace")
    ::Wait.until!(description: "http stub server #{server_name} started") do
      Net::HTTP.get_response(server_host, "/", server_port)
    end
  end

  after(:context) { Process.kill(9, @server_pid) }

  def server_name
    "example_server"
  end

  def server_host
    "localhost"
  end

  def server_port
    8001
  end

  def server_uri
    "http://#{server_host}:#{server_port}"
  end

end
