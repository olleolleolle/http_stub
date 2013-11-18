shared_context "server integration" do

  before(:all) do
    @pid = Process.spawn("rake example_server:start:foreground --trace")
    ::Wait.until!("http stub server started") { Net::HTTP.get_response(server_host, "/", server_port) }
  end

  after(:all) { Process.kill(9, @pid) }

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
