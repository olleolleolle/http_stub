shared_context "cross origin server integration" do

  before(:context) do
    @cross_origin_server_pid = Process.spawn("ruby #{File.dirname(__FILE__)}/application.rb")
    ::Wait.until!(description: "cross origin server started") do
      Net::HTTP.get_response(cross_origin_server_host, "/", cross_origin_server_port)
    end
  end

  after(:context) { Process.kill(9, @cross_origin_server_pid) }

  def cross_origin_server_host
    "localhost"
  end

  def cross_origin_server_port
    8005
  end

  def cross_origin_server_uri
    "http://#{cross_origin_server_host}:#{cross_origin_server_port}"
  end

end
