shared_context "server integration" do
  include Rack::Utils
  include HtmlHelpers

  before(:context) do
    @pid = Process.spawn("rake example_server:start:foreground --trace")
    ::Wait.until!(description: "http stub server started") { Net::HTTP.get_response(server_host, "/", server_port) }
  end

  after(:context) { Process.kill(9, @pid) }

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
