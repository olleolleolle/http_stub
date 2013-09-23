describe HttpStub::Server, "when the server is running" do
  include Rack::Utils
  include_context "server integration"

  let(:configurer) { HttpStub::Examples::ConfigurerWithManyActivators.new }

  describe "and a configurer with multiple stub activators is initialized" do

    before(:all) do
      HttpStub::Examples::ConfigurerWithManyActivators.host server_host
      HttpStub::Examples::ConfigurerWithManyActivators.port server_port
      HttpStub::Examples::ConfigurerWithManyActivators.initialize!
    end

    describe "GET #stubs/activators" do

      let(:response) { Net::HTTP.get_response(server_host, "/stubs/activators", server_port) }
      let(:response_document) { Nokogiri::HTML(response.body) }

      it "should return a 200 response code" do
        response.code.should eql("200")
      end

      it "should return response whose body contains a link to each activator in alphabetical order" do
        response_document.css("a").each_with_index do |link, i|
          link['href'].should eql("/activator#{i + 1}")
        end
      end

      it "should return a response whose body contains the uri of each activators stub" do
        (1..3).each { |i| response.body.should match(/#{escape_html("/path#{i}")}/) }
      end

      it "should return a response whose body contains the headers of each activators stub" do
        (1..3).each { |i| response.body.should match(/header#{i}:header_value#{i}/) }
      end

      it "should return a response whose body contains the parameters of each activators stub" do
        (1..3).each { |i| response.body.should match(/param#{i}=param_value#{i}/) }
      end

      it "should return a response whose body contains the response status of each activators stub" do
        (1..3).each { |i| response.body.should match(/20#{i}/) }
      end

      it "should return a response whose body contains the response body of each activators stub" do
        response.body.should match(/Plain text body/)
        response.body.should match(/#{escape_html({ "key" => "JSON body" }.to_json)}/)
        response.body.should match(/#{escape_html("<html><body>HTML body</body></html>")}/)
      end

    end

    describe "GET #stubs" do

      describe "when multiple stubs are configured" do

        before(:all) do
          (1..3).each { |i| Net::HTTP.get_response(server_host, "/activator#{i}", server_port) }
        end

        let(:response) { Net::HTTP.get_response(server_host, "/stubs", server_port) }
        let(:response_document) { Nokogiri::HTML(response.body) }

        it "should return a 200 response code" do
          response.code.should eql("200")
        end

        it "should return a response whose body contains the uri of each stub" do
          (1..3).each { |i| response.body.should match(/#{escape_html("/path#{i}")}/) }
        end

        it "should return a response whose body contains the headers of each stub" do
          (1..3).each { |i| response.body.should match(/header#{i}:header_value#{i}/) }
        end

        it "should return a response whose body contains the parameters of each stub" do
          (1..3).each { |i| response.body.should match(/param#{i}=param_value#{i}/) }
        end

        it "should return a response whose body contains the response status of each stub" do
          (1..3).each { |i| response.body.should match(/20#{i}/) }
        end

        it "should return a response whose body contains the response body of each stub" do
          response.body.should match(/Plain text body/)
          response.body.should match(/#{escape_html({ "key" => "JSON body" }.to_json)}/)
          response.body.should match(/#{escape_html("<html><body>HTML body</body></html>")}/)
        end

      end

    end

  end

end
