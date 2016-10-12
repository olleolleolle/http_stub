shared_context "server integration" do
  include Rack::Utils
  include HtmlHelpers

  let(:server_specification) { {} }
  let(:server_driver)        { HttpStub::Server::Driver.find_or_create(server_specification) }
  let(:server_host)          { server_driver.host }
  let(:server_port)          { server_driver.port }
  let(:server_uri)           { server_driver.uri }

  before(:example) { server_driver.start }

  def default_session_id
    server_driver.default_session_id
  end

  def establish_default_session(session_id)
    server_driver.default_session_id = session_id
  end

  def reset_session
    server_driver.reset_session
  end

end
