describe HttpStub::Server, "when the server is running" do
  include Rack::Utils
  include_context "server integration"

  let(:configurer) { HttpStub::Examples::ConfigurerWithManyActivators.new }

  describe "POST #stubs" do

    context "when provided with the minimum data required" do

      before(:each) do
        @response = HTTParty.post(
          "#{server_uri}/stubs",
          body: { uri: "/some/path", method: "get", response: { status: 200, body: "Some body" } }.to_json
        )
      end

      it "should return a 200 response code" do
        @response.code.should eql(200)
      end

      it "should register a stub returning the provided response for a matching request" do
        stubbed_response = HTTParty.get("#{server_uri}/some/path")

        stubbed_response.code.should eql(200)
        stubbed_response.body.should eql("Some body")
      end

    end

  end

  describe "and a configurer with multiple stub activators is initialized" do

    before(:all) do
      HttpStub::Examples::ConfigurerWithManyActivators.host(server_host)
      HttpStub::Examples::ConfigurerWithManyActivators.port(server_port)
      HttpStub::Examples::ConfigurerWithManyActivators.initialize!
    end

    describe "GET #stubs/activators" do

      let(:response) { HTTParty.get("#{server_uri}/stubs/activators") }
      let(:response_document) { Nokogiri::HTML(response.body) }

      it "should return a 200 response code" do
        response.code.should eql(200)
      end

      it "should return response whose body contains a link to each activator in alphabetical order" do
        response_document.css("a").each_with_index do |link, i|
          link['href'].should eql("/activator_#{i + 1}")
        end
      end

      it "should return a response whose body contains the uri of each activators stub" do
        (1..3).each { |i| response.body.should match(/#{escape_html("/path_#{i}")}/) }
      end

      it "should return a response whose body contains the request headers of each activators stub" do
        (1..3).each { |i| response.body.should match(/request_header_#{i}:request_header_value_#{i}/) }
      end

      it "should return a response whose body contains the parameters of each activators stub" do
        (1..3).each { |i| response.body.should match(/parameter_#{i}=parameter_value_#{i}/) }
      end

      it "should return a response whose body contains the response status of each activators stub" do
        (1..3).each { |i| response.body.should match(/20#{i}/) }
      end

      it "should return a response whose body contains the response headers of each activators stub" do
        (1..3).each { |i| response.body.should match(/response_header_#{i}:response_header_value_#{i}/) }
      end

      it "should return a response whose body contains the response body of each activators stub" do
        response.body.should match(/Plain text body/)
        response.body.should match(/#{escape_html({ "key" => "JSON body" }.to_json)}/)
        response.body.should match(/#{escape_html("<html><body>HTML body</body></html>")}/)
      end

      it "should return a response whose body contains the response delay of each activators stub" do
        (1..3).each { |i| response.body.should include("#{i * 8}") }
      end

    end

    describe "GET #stubs" do

      describe "when multiple stubs are configured" do

        before(:all) do
          (1..3).each { |i| HTTParty.get("#{server_uri}/activator_#{i}") }
        end

        let(:response) { HTTParty.get("#{server_uri}/stubs") }
        let(:response_document) { Nokogiri::HTML(response.body) }

        it "should return a 200 response code" do
          response.code.should eql(200)
        end

        it "should return a response whose body contains the uri of each stub" do
          (1..3).each { |i| response.body.should match(/#{escape_html("/path_#{i}")}/) }
        end

        it "should return a response whose body contains the headers of each stub" do
          (1..3).each { |i| response.body.should match(/request_header_#{i}:request_header_value_#{i}/) }
        end

        it "should return a response whose body contains the parameters of each stub" do
          (1..3).each { |i| response.body.should match(/parameter_#{i}=parameter_value_#{i}/) }
        end

        it "should return a response whose body contains the response status of each stub" do
          (1..3).each { |i| response.body.should match(/20#{i}/) }
        end

        it "should return a response whose body contains the response headers of each stub" do
          (1..3).each { |i| response.body.should match(/response_header_#{i}:response_header_value_#{i}/) }
        end

        it "should return a response whose body contains the response body of each stub" do
          response.body.should match(/Plain text body/)
          response.body.should match(/#{escape_html({ "key" => "JSON body" }.to_json)}/)
          response.body.should match(/#{escape_html("<html><body>HTML body</body></html>")}/)
        end

        it "should return a response whose body contains the response delay of each stub" do
          (1..3).each { |i| response.body.should include("#{i * 8}") }
        end

      end

    end

  end

end
