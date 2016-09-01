describe "Cross origin support acceptance" do
  include_context "cross origin server integration"
  include_context "browser integration"

  let(:cross_origin_page) { CrossOriginServer::IndexPage.new(browser) }

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

        let(:application_headers) do
          (1..3).each_with_object({}) { |i, result| result["APPLICATION_HEADER_#{i}"] = "header value #{i}" }
        end

        let(:response) { HTTParty.get("#{server_uri}/some_path", headers: application_headers) }

        before(:example) { cross_origin_page.wait_for_response_indicator("Succeeded") }

        it "responds with the scenario response" do
          expect(response.code).to eql(204)
        end

        it "responds with cross origin support headers" do
          expect_response_to_contain_cross_origin_support(method: "GET", header_names: application_headers.keys)
        end

      end

    end

    context "and a scenario configuring OPTIONS request reponses is activated" do

      before(:example) { stub_server.activate!("Options scenario") }

      context "and a matching pre-flight request is made" do

        let(:access_control_request_method)       { "PUT" }
        let(:access_control_request_header_names) { (1..3).map { |i| "ACCESS_CONTROL_HEADER_#{i}" } }
        let(:access_control_request_headers) do
          {
            "Access-Control-Request-Method"  => access_control_request_method,
            "Access-Control-Request-Headers" => access_control_request_header_names.join(",")
          }
        end

        let(:response) { HTTParty.options("#{server_uri}/some_path", headers: access_control_request_headers) }

        it "ignores the stub and replays the cross origin response" do
          expect(response.code).to eql(200)
          expect_response_to_contain_cross_origin_support(method:       access_control_request_method,
                                                          header_names: access_control_request_header_names)
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

      before(:example) { stub_server.activate!("Scenario 1") }

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

  def expect_response_to_contain_cross_origin_support(expectations)
    expect(response.headers["access-control-allow-origin"]).to eql("*")
    expect(response.headers["access-control-allow-methods"]).to eql(expectations[:method])
    expectations[:header_names].each do |expected_header_name|
      expect(response.headers["access-control-allow-headers"]).to include(expected_header_name)
    end

  end

end
