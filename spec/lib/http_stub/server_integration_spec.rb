describe HttpStub::Server, "when the server is running" do
  include Rack::Utils
  include_context "server integration"

  let(:configurer) { HttpStub::Examples::ConfigurerWithManyActivators.new }

  describe "POST #stubs" do

    context "when provided with the minimum data required" do

      before(:example) do
        @response = HTTParty.post(
          "#{server_uri}/stubs",
          body: { uri: "/some/path", method: "get", response: { status: 200, body: "Some body" } }.to_json
        )
      end

      it "returns a 200 response code" do
        expect(@response.code).to eql(200)
      end

      it "registers a stub returning the provided response for a matching request" do
        stubbed_response = HTTParty.get("#{server_uri}/some/path")

        expect(stubbed_response.code).to eql(200)
        expect(stubbed_response.body).to eql("Some body")
      end

    end

  end

  describe "and a configurer with multiple stub activators is initialized" do

    before(:context) do
      HttpStub::Examples::ConfigurerWithManyActivators.host(server_host)
      HttpStub::Examples::ConfigurerWithManyActivators.port(server_port)
      HttpStub::Examples::ConfigurerWithManyActivators.initialize!
    end

    describe "GET #stubs/activators" do

      let(:response) { HTTParty.get("#{server_uri}/stubs/activators") }
      let(:response_document) { Nokogiri::HTML(response.body) }

      it "returns a 200 response code" do
        expect(response.code).to eql(200)
      end

      it "returns response whose body contains a link to each activator in alphabetical order" do
        response_document.css("a").each_with_index do |link, i|
          expect(link['href']).to eql("/activator_#{i + 1}")
        end
      end

      it "returns a response whose body contains the uri of each activators stub" do
        (1..3).each { |i| expect(response.body).to match(/#{escape_html("/path_#{i}")}/) }
      end

      it "returns a response whose body contains the request headers of each activators stub" do
        (1..3).each { |i| expect(response.body).to match(/request_header_#{i}:request_header_value_#{i}/) }
      end

      it "returns a response whose body contains the parameters of each activators stub" do
        (1..3).each { |i| expect(response.body).to match(/parameter_#{i}=parameter_value_#{i}/) }
      end

      it "returns a response whose body contains the response status of each activators stub" do
        (1..3).each { |i| expect(response.body).to match(/20#{i}/) }
      end

      it "returns a response whose body contains the response headers of each activators stub" do
        (1..3).each { |i| expect(response.body).to match(/response_header_#{i}:response_header_value_#{i}/) }
      end

      it "returns a response whose body contains the response body of each activators stub" do
        expect(response.body).to match(/Plain text body/)
        expect(response.body).to match(/#{escape_html({ "key" => "JSON body" }.to_json)}/)
        expect(response.body).to match(/#{escape_html("<html><body>HTML body</body></html>")}/)
      end

      it "returns a response whose body contains the response delay of each activators stub" do
        (1..3).each { |i| expect(response.body).to include("#{i * 8}") }
      end

    end

    describe "GET #stubs" do

      describe "when multiple stubs are configured" do

        before(:context) do
          (1..3).each { |i| HTTParty.get("#{server_uri}/activator_#{i}") }
        end

        let(:response) { HTTParty.get("#{server_uri}/stubs") }
        let(:response_document) { Nokogiri::HTML(response.body) }

        it "returns a 200 response code" do
          expect(response.code).to eql(200)
        end

        it "returns a response whose body contains the uri of each stub" do
          (1..3).each { |i| expect(response.body).to match(/#{escape_html("/path_#{i}")}/) }
        end

        it "returns a response whose body contains the headers of each stub" do
          (1..3).each { |i| expect(response.body).to match(/request_header_#{i}:request_header_value_#{i}/) }
        end

        it "returns a response whose body contains the parameters of each stub" do
          (1..3).each { |i| expect(response.body).to match(/parameter_#{i}=parameter_value_#{i}/) }
        end

        it "returns a response whose body contains the response status of each stub" do
          (1..3).each { |i| expect(response.body).to match(/20#{i}/) }
        end

        it "returns a response whose body contains the response headers of each stub" do
          (1..3).each { |i| expect(response.body).to match(/response_header_#{i}:response_header_value_#{i}/) }
        end

        it "returns a response whose body contains the response body of each stub" do
          expect(response.body).to match(/Plain text body/)
          expect(response.body).to match(/#{escape_html({ "key" => "JSON body" }.to_json)}/)
          expect(response.body).to match(/#{escape_html("<html><body>HTML body</body></html>")}/)
        end

        it "returns a response whose body contains the response delay of each stub" do
          (1..3).each { |i| expect(response.body).to include("#{i * 8}") }
        end

      end

    end

  end

end
