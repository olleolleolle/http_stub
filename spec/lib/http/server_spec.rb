describe Http::Stub::Server do
  include Rack::Test::Methods

  let(:app) { Http::Stub::Server }
  let(:response) { last_response }
  let(:response_body) { response.body.to_s }

  shared_examples "a server that stubs a response" do |options|

    let(:request_type) { options[:request_type] }
    let(:different_request_type) { options[:different_request_type] }
    let(:test_url) { "/test_#{request_type}" }

    before(:each) do
      post "/stub", '{"uri": "' + test_url + '", "method": "' + request_type.to_s + '", "response": {"status":"200", "body":"Foo"}}'
    end

    describe "when a #{options[:request_type]} request is made" do

      before(:each) { self.send(request_type, test_url) }

      it "should respond with the stubbed response code" do
        response.status.should eql(200)
      end

      it "should respond with the stubbed body" do
        response_body.should eql("Foo")
      end

    end

    describe "and a request of type '#{options[:different_request_type]}' is made" do

      before(:each) { self.send(different_request_type, test_url) }

      it "should respond with a 404 response code" do
        response.status.should eql(404)
      end

    end

  end

  all_request_types = [:get, :post, :put, :delete, :patch, :options]
  all_request_types.each_with_index do |request_type, i|

    describe "when a #{request_type} request is stubbed" do

      it_should_behave_like "a server that stubs a response", request_type: request_type, different_request_type: all_request_types[i - 1]

    end

  end

  describe "when a request is made that is not stubbed" do

    before(:each) { get "/not_stubbed" }

    it "should respond with 404 response code" do
      response.status.should eql(404)
    end

  end

end
