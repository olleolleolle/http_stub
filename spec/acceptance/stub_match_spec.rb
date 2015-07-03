describe "Stub match acceptance" do
  include_context "configurer integration"

  before(:example) { configurer.initialize! }

  after(:example) { configurer.clear_stubs! }

  describe "GET /stubs/matches" do

    let(:uri)            { "/some/uri" }
    let(:request_method) { :get }
    let(:headers)        { (1..3).map { |i| [ "header_#{i}", "header value #{i}" ] }.to_h }
    let(:parameters)     { {} }
    let(:body)           { nil }

    let(:response)          { HTTParty.get("#{server_uri}/stubs/matches") }
    let(:response_document) { Nokogiri::HTML(response.body) }

    shared_context "behaviours of a request that is recorded in the stub match log" do

      it "returns a response body that contains the uri of the request" do
        expect(response.body).to match(/#{escape_html(uri)}/)
      end

      it "returns a response body that contains the method of the request" do
        expect(response.body).to match(/#{escape_html(request_method)}/)
      end

      it "returns a response body that contains the headers of the request whose names are in uppercase" do
        headers.each do |expected_header_key, expected_header_value|
          expect(response.body).to match(/#{expected_header_key.upcase}:#{expected_header_value}/)
        end
      end

      context "when the request contains parameters" do

        let(:parameters) { (1..3).map { |i| [ "parameter_#{i}", "parameter value #{i}" ] }.to_h }

        it "returns a response body that contain the parameters" do
          parameters.each do |expected_parameter_key, expected_parameter_value|
            expect(response.body).to match(/#{expected_parameter_key}=#{expected_parameter_value}/)
          end
        end

        def issue_request
          HTTParty.send(request_method, "#{server_uri}#{uri}", headers: headers, query: parameters)
        end

      end

      context "when the request contains a body" do

        let(:body) { "Some <strong>request body</strong>" }

        it "returns a response body that contains the body" do
          expect(response.body).to match(/#{escape_html(body)}/)
        end

        def issue_request
          HTTParty.send(request_method, "#{server_uri}#{uri}", headers: headers, body: body)
        end

      end

      def issue_request
        HTTParty.send(request_method, "#{server_uri}#{uri}", headers: headers)
      end

    end

    context "when a request has been made matching a stub" do

      before(:example) do
        register_stub

        issue_request
      end

      include_context "behaviours of a request that is recorded in the stub match log"

      it "returns a response body that contains a link to the matched stub" do
        stub_link = response_document.css("a.stub").first
        expect(full_stub_uri).to end_with(stub_link["href"])
      end

      def full_stub_uri
        @register_stub_response.header["location"]
      end

    end

    context "when a request has been made that does not match a stub" do

      before(:example) { issue_request }

      it_behaves_like "behaviours of a request that is recorded in the stub match log"

    end

    context "when a request has been made configuring a stub" do

      before(:example) { register_stub }

      it "should not be recorded in the stub request log" do
        expect(response.body).to_not match(/#{uri}/)
      end

    end

    context "when a request has been made configuring a scenarios" do

      before(:example) { register_scenario }

      it "should not be recorded in the stub request log" do
        expect(response.body).to_not match(/#{uri}/)
      end

      def register_scenario
        stub_server.add_scenario_with_one_stub!("some_scenario", build_stub)
      end

    end

    def register_stub
      @register_stub_response = stub_server.add_stub!(build_stub)
    end

    def build_stub
      stub_server.build_stub do |stub|
        stub.match_requests(uri: uri, method: request_method, headers: headers, parameters: parameters, body: body)
        stub.respond_with(status: 200, body: "Some body")
      end

    end

  end

end
