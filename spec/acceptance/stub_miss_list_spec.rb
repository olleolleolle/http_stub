describe "Stub miss list acceptance" do
  include_context "configurer integration with stubs recalled"

  describe "GET /http_stub/stubs/misses" do

    let(:response)          { HTTParty.get("#{server_uri}/http_stub/stubs/misses") }
    let(:response_document) { Nokogiri::HTML(response.body) }

    before(:example) { configure_stub_registrator }

    context "when a request has been made that does not match a stub" do

      before(:example) { stub_registrator.issue_matching_request }

      include_context "HTML view including request details"

    end

    context "when a request has been made matching a stub" do

      before(:example) do
        stub_registrator.register_stub

        stub_registrator.issue_matching_request
      end

      include_context "HTML view excluding request details"

    end

    context "when a request has been made configuring a stub" do

      before(:example) { stub_registrator.register_stub }


      include_context "HTML view excluding request details"

    end

    context "when a request has been made configuring a scenario" do

      before(:example) { stub_registrator.register_scenario }

      include_context "HTML view excluding request details"

    end

    def configure_stub_registrator
      # intentionally blank
    end

  end

end
