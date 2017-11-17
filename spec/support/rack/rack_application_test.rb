shared_context "rack application test" do
  include Rack::Test::Methods

  let(:response)      { last_response }
  let(:response_body) { response.body.to_s }

  let(:app)           { app_class.new! }

end
