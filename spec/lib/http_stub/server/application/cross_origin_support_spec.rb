describe HttpStub::Server::Application::CrossOriginSupport do
  include Rack::Test::Methods

  let(:header_names)    { (1..3).map { |i| "HEADER_#{i}" } }
  let(:request_headers) do
    header_names.each_with_object({}) { |name, result| result["HTTP_#{name}"] = "#{name} value" }
  end

  let(:response) { last_response }

  let(:app_class) { Class.new(Sinatra::Base) }

  let(:app) { app_class.new! }

  before(:example) do
    app_class.before { @http_stub_request = HttpStub::Server::Request.create(request) }
  end

  describe "when registered in an application" do

    before(:example) { app_class.register described_class }

    shared_examples_for "a request whose response contains access control headers" do

      it "responds with an access control origin header allowing requests from all origins" do
        subject

        expect(response.headers["Access-Control-Allow-Origin"]).to eql("*")
      end

      it "responds with an access control method header allowing the method of the current request" do
        subject

        expect(response.headers["Access-Control-Allow-Methods"]).to eql(request_method)
      end

      it "responds with an access control headers header allowing the headers of the current request" do
        subject

        header_names.each do |expected_header_name|
          expect(response.headers["Access-Control-Allow-Headers"]).to include(expected_header_name)
        end
      end

    end

    context "and cross origin support is enabled" do

      before(:example) { app_class.enable :cross_origin_support }

      context "and a non-OPTIONS request is issued" do

        let(:request_method) { "GET" }

        subject { get "/some_resource", {}, request_headers }

        it_behaves_like "a request whose response contains access control headers"

      end


      context "and an OPTIONS request is issued" do

        let(:request_method) { "OPTIONS" }

        subject { options "/some_resource", {}, request_headers }

        it_behaves_like "a request whose response contains access control headers"

        it "responds with a status of 200" do
          subject

          expect(response.status).to eql(200)
        end

      end

    end

    context "and cross origin support is disabled" do

      before(:example) do
        app_class.disable :cross_origin_support
      end

      context "and a non-OPTIONS request is issued" do

        subject { get "/some_resource", {}, request_headers }

        it "does not add access control headers" do
          subject

          header_names.each { |header_name| expect(header_name).to_not match(/^Access-Control/) }
        end

      end

      context "and an OPTIONS request is issued" do

        subject { options "/some_resource" }

        it "returns a not found response" do
          subject

          expect(response.status).to eql(404)
        end

      end

    end

  end

end
