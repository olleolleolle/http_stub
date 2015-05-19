describe HttpStub::Server::Application, "when the server is running" do
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
      configurer = HttpStub::Examples::ConfigurerWithManyActivators
      configurer.host(server_host)
      configurer.port(server_port)
      configurer.initialize!
    end

    shared_context "the response contains HTML describing the configurers stubs" do

      it "returns a 200 response code" do
        expect(response.code).to eql(200)
      end

      it "returns a response whose body contains the uri of each stub" do
        (1..3).each do |stub_number|
          expect(response.body).to match(/#{escape_html("/path_#{stub_number}")}/)
        end
      end

      it "returns a response whose body contains the uri of each stub trigger" do
        (1..3).each do |stub_number|
          (1..3).each do |trigger_number|
            expect(response.body).to match(/#{escape_html("/path_#{stub_number}_trigger_#{trigger_number}")}/)
          end
        end
      end

      it "returns a response whose body contains the request headers of each stub" do
        (1..3).each do |stub_number|
          expect(response.body).to match(/request_header_#{stub_number}:request_header_value_#{stub_number}/)
        end
      end

      it "returns a response whose body contains the request headers of each stub trigger" do
        (1..3).each do |stub_number|
          (1..3).each do |trigger_number|
            expected_header_key = "request_header_#{stub_number}_trigger_#{trigger_number}"
            expected_header_value = "request_header_value_#{stub_number}_trigger_#{trigger_number}"
            expect(response.body).to match(/#{expected_header_key}:#{expected_header_value}/)
          end
        end
      end

      it "returns a response whose body contains the parameters of each stub" do
        (1..3).each do |stub_number|
          expect(response.body).to match(/parameter_#{stub_number}=parameter_value_#{stub_number}/)
        end
      end

      it "returns a response whose body contains the parameters of each stub trigger" do
        (1..3).each do |stub_number|
          (1..3).each do |trigger_number|
            expected_parameter_key = "parameter_#{stub_number}_trigger_#{trigger_number}"
            expected_parameter_value = "parameter_value_#{stub_number}_trigger_#{trigger_number}"
            expect(response.body).to match(/#{expected_parameter_key}=#{expected_parameter_value}/)
          end
        end
      end

      it "returns a response whose body contains the response status of each stub" do
        (1..3).each { |stub_number| expect(response.body).to match(/20#{stub_number}/) }
      end

      it "returns a response whose body contains the response status of each stub trigger" do
        (1..3).each do |stub_number|
          (1..3).each do |trigger_number|
            expect(response.body).to match(/30#{stub_number * trigger_number}/)
          end
        end
      end

      it "returns a response whose body contains the response headers of each stub" do
        (1..3).each do |stub_number|
          expected_header_key = "response_header_#{stub_number}"
          expected_header_value = "response_header_value_#{stub_number}"
          expect(response.body).to match(/#{expected_header_key}:#{expected_header_value}/)
        end
      end

      it "returns a response whose body contains the response headers of each stub trigger" do
        (1..3).each do |stub_number|
          (1..3).each do |trigger_number|
            expected_header_key = "response_header_#{stub_number}_trigger_#{trigger_number}"
            expected_header_value = "response_header_value_#{stub_number}_trigger_#{trigger_number}"
            expect(response.body).to match(/#{expected_header_key}:#{expected_header_value}/)
          end
        end
      end

      it "returns a response whose body contains the response body of each stub" do
        expect(response.body).to match(/Plain text body/)
        expect(response.body).to match(/#{escape_html({ "key" => "JSON body" }.to_json)}/)
        expect(response.body).to match(/#{escape_html("<html><body>HTML body</body></html>")}/)
      end

      it "returns a response whose body contains the response body of each stub trigger" do
        (1..3).each do |stub_number|
          (1..3).each do |trigger_number|
            expect(response.body).to match(/Body of activator #{stub_number}_trigger_#{trigger_number}/)
          end
        end
      end

      it "returns a response whose body contains the response delay of each stub" do
        (1..3).each { |stub_number| expect(response.body).to include("#{8 * stub_number}") }
      end

      it "returns a response whose body contains the response delay of each stub trigger" do
        (1..3).each do |stub_number|
          (1..3).each do |trigger_number|
            expect(response.body).to include("#{3 * stub_number * trigger_number}")
          end
        end
      end

    end

    describe "GET #stubs/activators" do

      let(:response)          { HTTParty.get("#{server_uri}/stubs/activators") }
      let(:response_document) { Nokogiri::HTML(response.body) }

      it "returns response whose body contains links to each activator in alphabetical order" do
        response_document.css("a").each_with_index do |link, i|
          expect(link['href']).to eql("/activator_#{i + 1}")
        end
      end

      include_context "the response contains HTML describing the configurers stubs"

    end

    describe "GET #stubs" do

      describe "when multiple stubs are configured" do

        before(:context) do
          (1..3).each { |i| HTTParty.get("#{server_uri}/activator_#{i}") }
        end

        let(:response)          { HTTParty.get("#{server_uri}/stubs") }
        let(:response_document) { Nokogiri::HTML(response.body) }

        include_context "the response contains HTML describing the configurers stubs"

      end

    end

  end

end
