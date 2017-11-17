describe "Stub control value acceptance" do
  include_context "server integration"

  let(:configurator) { HttpStub::Examples::ConfiguratorWithStubControlValues }

  context "when a stub match uri has regular expression containing meta characters" do

    context "and a request is made whose uri matches the regular expression" do

      let(:response) { HTTParty.get("#{server_uri}/match/stub/regexp/$key=value") }

      it "replays the stubbed body" do
        expect(response.body).to eql("Regular expression uri stub body")
      end

    end

    context "and a request is made whose uri does not match the regular expression" do

      let(:response) { HTTParty.get("#{server_uri}/stub/no_match/regexp") }

      it "responds with a 404 status code" do
        expect(response.code).to eql(404)
      end

    end

  end

  context "when stub match headers" do

    context "have regular expression values" do

      let(:response) do
        HTTParty.get("#{server_uri}/stub_with_regular_expression_headers", headers: { "key" => header_value })
      end

      context "and a request that matches is made" do

        let(:header_value) { "matching_value" }

        it "replays the stubbed response" do
          expect(response.body).to eql("Regular expression headers stub body")
        end

      end

      context "and a request that does not match is made" do

        let(:header_value) { "does_not_match_value" }

        it "responds with a 404 status code" do
          expect(response.code).to eql(404)
        end

      end

    end

    context "have values indicating they must be omitted" do

      context "and a request that matches is made" do

        let(:response) { HTTParty.get("#{server_uri}/stub_with_omitted_headers") }

        it "replays the stubbed response" do
          expect(response.body).to eql("Omitted headers stub body")
        end

      end

      context "and a request that does not match is made" do

        let(:headers)  { { "key" => "must_be_omitted" } }
        let(:response) { HTTParty.get("#{server_uri}/stub_with_omitted_headers", headers: headers) }

        it "responds with a 404 status code" do
          expect(response.code).to eql(404)
        end

      end

    end

  end

  context "when stub match parameters" do

    context "have regular expression values" do

      let(:response) do
        HTTParty.get("#{server_uri}/stub_with_regular_expression_parameters", query: { "key" => parameter_value })
      end

      context "and a request that matches is made" do

        let(:parameter_value) { "matching_value" }

        it "replays the stubbed response" do
          expect(response.body).to eql("Regular expression parameters stub body")
        end

      end

      context "and a request that does not match is made" do

        let(:parameter_value) { "does_not_match_value" }

        it "responds with a 404 status code" do
          expect(response.code).to eql(404)
        end

      end

    end

    context "have values indicating they must be omitted" do

      context "and a request that matches is made" do

        let(:response) { HTTParty.get("#{server_uri}/stub_with_omitted_parameters") }

        it "replays the stubbed response" do
          expect(response.body).to eql("Omitted parameters stub body")
        end

      end

      context "and a request that does not match is made" do

        let(:parameters) { { "key" => "must_be_omitted" } }
        let(:response)   { HTTParty.get("#{server_uri}/stub_with_omitted_parameters", query: parameters) }

        it "responds with a 404 status code" do
          expect(response.code).to eql(404)
        end

      end

    end

  end

  context "when stub has a response delay" do

    it "delays the response by the time provided" do
      start_time = Time.now

      HTTParty.get("#{server_uri}/stub_with_response_delay")

      expect(Time.now - start_time).to be >= 1.0
    end

  end

end
