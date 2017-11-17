describe HttpStub::Server::Application::CrossOriginSupport do
  include_context "rack application test"

  describe "when registered in an application" do

    class HttpStub::Server::Application::CrossOriginSupportTestApplication < Sinatra::Base

      def http_stub_request
        HttpStub::Server::RequestFixture.create(rack_request: request)
      end

    end

    let(:application_header_names) { (1..3).map { |i| "APPLICATION_HEADER_#{i}" } }
    let(:application_headers)      do
      application_header_names.each_with_object({}) { |name, result| result["HTTP_#{name}"] = "#{name} value" }
    end

    let(:access_control_request_method)       { "PATCH" }
    let(:access_control_request_header_names) { (1..3).map { |i| "ACCESS_CONTROL_HEADER_#{i}" } }
    let(:access_control_request_headers)      do
      {
        "ACCESS_CONTROL_REQUEST_METHOD"  => access_control_request_method,
        "ACCESS_CONTROL_REQUEST_HEADERS" => access_control_request_header_names.join(",")
      }
    end

    let(:app_class) { HttpStub::Server::Application::CrossOriginSupportTestApplication }

    before(:example) { app_class.register(described_class) }

    shared_examples_for "a request whose response contains access control headers" do

      it "responds with an access control origin header allowing requests from all origins" do
        subject

        expect(response.headers["Access-Control-Allow-Origin"]).to eql("*")
      end

      it "responds with an access control method header allowing the method of the current request" do
        subject

        expect(response.headers["Access-Control-Allow-Methods"]).to eql(allowed_request_methods)
      end

      it "responds with an access control headers header allowing the headers of the current request" do
        subject

        expect(response.headers["Access-Control-Allow-Headers"]).to include(allowed_request_headers)
      end

    end

    context "and cross origin support is enabled" do

      before(:example) { app_class.enable :cross_origin_support }

      context "and a non-OPTIONS request is issued" do

        let(:request_headers) { application_headers }

        let(:allowed_request_methods) { "GET" }
        let(:allowed_request_headers) { application_header_names.join(",") }

        subject { get "/some_resource", {}, request_headers }

        it_behaves_like "a request whose response contains access control headers"

      end

      context "and a pre-flight OPTIONS request is issued" do

        let(:request_headers) { access_control_request_headers }

        let(:allowed_request_methods) { access_control_request_method }
        let(:allowed_request_headers) { access_control_request_header_names.join(",") }

        subject { options "/some_resource", {}, request_headers }

        it_behaves_like "a request whose response contains access control headers"

        it "responds with a status of 200" do
          subject

          expect(response.status).to eql(200)
        end

      end

    end

    context "and cross origin support is disabled" do

      before(:example) { app_class.disable :cross_origin_support }

      context "and a non-OPTIONS request is issued" do

        subject { get "/some_resource", {}, application_headers }

        it "does not add access control headers" do
          subject

          response.headers.keys.each { |header_name| expect(header_name).to_not include("Access-Control") }
        end

      end

      context "and an OPTIONS request is issued" do

        subject { options "/some_resource", {}, access_control_request_headers }

        it "returns a not found response" do
          subject

          expect(response.status).to eql(404)
        end

      end

    end

  end

end
