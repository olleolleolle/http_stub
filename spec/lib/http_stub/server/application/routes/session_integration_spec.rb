describe HttpStub::Server::Application::Routes::Session, "when a server is running" do
  include_context "server integration"

  let(:response_document) { Nokogiri::HTML(response.body) }

  before(:example) { HTTParty.post("#{server_uri}/http_stub/status/initialized") }

  describe "GET /http_stub" do

    let(:response) { HTTParty.get("#{server_uri}/http_stub") }

    let(:transactional_session_parameter) { "http_stub_session_id=#{transactional_session_id}" }

    it "returns a 200 response code" do
      expect(response.code).to eql(200)
    end

    it "returns a response whose body links to the scenarios list for the transactional session" do
      expect(link_for("scenarios")).to eql("/http_stub/scenarios?#{transactional_session_parameter}")
    end

    it "returns a response whose body links to the stubs list for the transactional session" do
      expect(link_for("stubs")).to eql("/http_stub/stubs?#{transactional_session_parameter}")
    end

    it "returns a response whose body links to the matches list for the transactional session" do
      expected_matches_link = "/http_stub/stubs/matches?#{transactional_session_parameter}"

      expect(link_for("stub_matches")).to eql(expected_matches_link)
    end

    it "returns a response whose body links to the misses list for the transactional session" do
      expected_misses_link = "/http_stub/stubs/misses?#{transactional_session_parameter}"

      expect(link_for("stub_misses")).to eql(expected_misses_link)
    end

    def link_for(id)
      response_document.at_css("a##{id}")["href"]
    end

  end

end
