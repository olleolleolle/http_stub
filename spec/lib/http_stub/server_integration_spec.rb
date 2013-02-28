describe HttpStub::Server, "when the server is running" do
  include Rack::Utils
  include_context "server integration"

  let(:configurer) { HttpStub::Examples::ConfigurerWithManyAliases.new }

  describe "and a configurer with multiple aliases is initialized" do

    before(:all) { configurer.class.initialize! }

    describe "GET #stubs/aliases" do

      let(:response) { Net::HTTP.get_response("localhost", "/stubs/aliases", 8001) }
      let(:response_document) { Nokogiri::HTML(response.body) }

      it "should return a 200 response code" do
        response.code.should eql("200")
      end

      it "should return response whose body contains a link to each alias in alphabetical order" do
        response_document.css("a").each_with_index do |link, i|
          link['href'].should eql("/alias#{i + 1}")
        end
      end

      it "should return a response whose body contains the uri of each alias stub" do
        (1..3).each { |i| response.body.should match(/#{escape_html("/path#{i}")}/) }
      end

      it "should return a response whose body contains the parameters of each alias stub" do
        (1..3).each { |i| response.body.should match(/param#{i}=value#{i}/) }
      end

      it "should return a response whose body contains the response status of each alias stub" do
        (1..3).each { |i| response.body.should match(/20#{i}/) }
      end

      it "should return a response whose body contains the response body of each alias stub" do
        response.body.should match(/Plain text body/)
        response.body.should match(/#{escape_html({ "key" => "JSON body" }.to_json)}/)
        response.body.should match(/#{escape_html("<html><body>HTML body</body></html>")}/)
      end

    end

    describe "GET #stubs" do

      describe "when multiple stubs are configured" do

        before(:all) do
          (1..3).each { |i| Net::HTTP.get_response("localhost", "/alias#{i}", 8001) }
        end

        let(:response) { Net::HTTP.get_response("localhost", "/stubs", 8001) }
        let(:response_document) { Nokogiri::HTML(response.body) }

        it "should return a 200 response code" do
          response.code.should eql("200")
        end

        it "should return a response whose body contains the uri of each stub" do
          (1..3).each { |i| response.body.should match(/#{escape_html("/path#{i}")}/) }
        end

        it "should return a response whose body contains the parameters of each alias stub" do
          (1..3).each { |i| response.body.should match(/param#{i}=value#{i}/) }
        end

        it "should return a response whose body contains the response status of each alias stub" do
          (1..3).each { |i| response.body.should match(/20#{i}/) }
        end

        it "should return a response whose body contains the response body of each alias stub" do
          response.body.should match(/Plain text body/)
          response.body.should match(/#{escape_html({ "key" => "JSON body" }.to_json)}/)
          response.body.should match(/#{escape_html("<html><body>HTML body</body></html>")}/)
        end

      end

    end

  end

end
