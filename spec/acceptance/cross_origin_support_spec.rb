describe "Cross origin support acceptance" do
  include_context "cross origin server integration"
  include_context "browser integration"

  let(:cross_origin_page) { CrossOriginServer::IndexPage.new(browser) }

  let(:headers) { (1..3).each_with_object({}) { |i, result| result["HEADER_#{i}"] = "header value #{i}" } }

  context "when a stub server with cross origin support is initialized" do
    include_context "configurer integration"

    def server_name
      "cross_origin_stub"
    end

    let(:configurer) { HttpStub::Examples::ConfigurerWithCrossOriginSupport.new }

    before(:example) { configurer.class.initialize! }

    context "and a browser page rendered by a different server requests a scenario be activated" do

      before(:example) do
        cross_origin_page.load_and_wait_until_available
        cross_origin_page.activate_scenario("Get scenario")
      end

      context "the browser" do

        it "receives a successful response" do
          cross_origin_page.wait_for_response_indicator("Succeeded")
        end

      end

      context "and a matching request is made" do

        let(:response) { HTTParty.get("#{server_uri}/some_path", headers: headers) }

        before(:example) { cross_origin_page.wait_for_response_indicator("Succeeded") }

        it "responds with the scenario response" do
          expect(response.code).to eql(204)
        end

        it "responds with cross origin support headers" do
          expect_response_to_contain_cross_origin_headers("GET")
        end

      end

    end

    context "and a scenario configuring OPTIONS request reponses is activated" do

      before(:example) { configurer.activate!("Options scenario") }

      context "and a matching request is made" do

        let(:response) { HTTParty.options("#{server_uri}/some_path", headers: headers) }

        it "ignores the stub and replays a cross origin options response" do
          expect(response.code).to eql(200)
          expect_response_to_contain_cross_origin_headers("OPTIONS")
        end

      end

    end

  end

  context "when a stub server without cross origin support is initialized" do
    include_context "configurer integration"

    let(:configurer) { HttpStub::Examples::ConfigurerWithTrivialScenarios.new }

    before(:example) { configurer.class.initialize! }

    context "and a browser page rendered by a different server requests a scenario be activated" do

      before(:example) do
        cross_origin_page.load_and_wait_until_available
        cross_origin_page.activate_scenario("Get scenario")
      end

      context "the browser" do

        it "receives an unsuccessful response" do
          cross_origin_page.wait_for_response_indicator("Failed")
        end

      end

    end

    context "and a scenario is activated" do

      before(:example) { configurer.activate!("Scenario 1") }

      context "and a matching request is made" do

        let(:response) { HTTParty.options("#{server_uri}/scenario_stub_path_1") }

        it "responds without cross origin support headers" do
          %w{ access-control-allow-origin
              access-control-allow-methods
              access-control-allow-headers }.each do |header_name|
            expect(response.headers.keys).to_not include(header_name)
          end
        end

      end

    end

  end

  def expect_response_to_contain_cross_origin_headers(method_name)
    expect(response.headers["access-control-allow-origin"]).to eql("*")
    expect(response.headers["access-Control-allow-methods"]).to eql(method_name)
    headers.keys.each do |expected_header_name|
      expect(response.headers["access-control-allow-headers"]).to include(expected_header_name)
    end

  end

end
