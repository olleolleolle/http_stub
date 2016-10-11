shared_context "server integration" do
  include Rack::Utils
  include HtmlHelpers

  before(:context) do
    @server_driver = HttpStub::Server::Driver.new(server_name)
    @server_driver.start
  end

  after(:context) { @server_driver.stop }

  def server_name
    "example_server"
  end

  def server_host
    @server_driver.host
  end

  def server_port
    @server_driver.port
  end

  def server_uri
    @server_driver.uri
  end

  def default_session_id
    @server_driver.default_session_id
  end

  def establish_default_session(session_id)
    @server_driver.default_session_id = session_id
  end

  def reset_session
    @server_driver.reset_session
  end

end
