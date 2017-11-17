describe "Stub miss list acceptance" do
  include_context "server integration"

  describe "GET /http_stub/stubs/misses" do
    include_context "configurator with stub builder and requester"

    let(:request_prior_to_miss_list_request) { nil }

    let(:response)          do
      request_prior_to_miss_list_request
      HTTParty.get("#{server_uri}/http_stub/stubs/misses")
    end
    let(:response_document) { Nokogiri::HTML(response.body) }

    context "when no miss has been registered" do

      it "returns a response with an empty request list" do
        expect(response.body).to_not include("Request")
      end

    end

    context "when the only request made activates a scenario" do

      let(:configurator) { HttpStub::Examples::ConfiguratorWithTrivialScenarios }

      let(:request_prior_to_miss_list_request) { client.activate!("Scenario 1") }

      it "returns a response with an empty request list" do
        expect(response.body).to_not include("Request")
      end

    end

    context "when a request has been made that does not match a stub" do

      let(:request_prior_to_miss_list_request) { stub_requester.issue_non_matching_request }

      include_context "HTML view including a stub request"

    end

    context "when a request has been made matching a stub" do

      let(:request_prior_to_miss_list_request) { stub_requester.issue_matching_request }

      include_context "HTML view excluding a stub request"

    end

  end

end
