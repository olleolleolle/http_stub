describe "Stub control value acceptance" do
  include_context "configurer integration"

  let(:configurer)  { HttpStub::Examples::ConfigurerWithClassStub.new }

  before(:example) { configurer.class.initialize! }

  context "when a stub is submitted" do

    context "with a stub uri that is regular expression containing meta characters" do

      before(:example) do
        configurer.stub_response!(/\/stub\/regexp\/\$key=value/, method: :get, response: { body: "Stub body" })
      end

      context "and a request is made whose uri matches the regular expression" do

        let(:response) { HTTParty.get("#{server_uri}/match/stub/regexp/$key=value") }

        it "replays the stubbed body" do
          expect(response.body).to eql("Stub body")
        end

      end

      context "and a request is made whose uri does not match the regular expression" do

        let(:response) { HTTParty.get("#{server_uri}/stub/no_match/regexp") }

        it "responds with a 404 status code" do
          expect(response.code).to eql(404)
        end

      end

    end

    context "with headers whose values are regular expressions" do

      before(:example) do
        configurer.stub_response!(
          "/stub_with_headers", method: :get, headers: { key: /^match.*/ },
          response: { status: 202, body: "Another stub body" }
        )
      end

      context "and a request that matches is made" do

        let(:response) do
          HTTParty.get("#{server_uri}/stub_with_headers", headers: { "key" => "matching_value" })
        end

        it "replays the stubbed response" do
          expect(response.code).to eql(202)
          expect(response.body).to eql("Another stub body")
        end

      end

      context "and a request that does not match is made" do

        let(:response) do
          HTTParty.get("#{server_uri}/stub_with_headers", headers: { "key" => "does_not_match_value" })
        end

        it "responds with a 404 status code" do
          expect(response.code).to eql(404)
        end

      end

    end

    context "with parameters" do

      context "whose values are regular expressions" do

        before(:example) do
          configurer.stub_response!(
            "/stub_with_parameters", method: :get, parameters: { key: /^match.*/ },
            response: { status: 202, body: "Another stub body" }
          )
        end

        context "and a request that matches is made" do

          let(:response) { HTTParty.get("#{server_uri}/stub_with_parameters?key=matching_value") }

          it "replays the stubbed response" do
            expect(response.code).to eql(202)
            expect(response.body).to eql("Another stub body")
          end

        end

        context "and a request that does not match is made" do

          let(:response) { HTTParty.get("#{server_uri}/stub_with_parameters?key=does_not_match_value") }

          it "responds with a 404 status code" do
            expect(response.code).to eql(404)
          end

        end

      end

      context "whose values indicate the parameters must be omitted" do

        before(:example) do
          configurer.stub_response!(
            "/stub_with_omitted_parameters", method: :get, parameters: { key: :omitted },
            response: { status: 202, body: "Omitted parameter stub body" }
          )
        end

        context "and a request that matches is made" do

          let(:response) { HTTParty.get("#{server_uri}/stub_with_omitted_parameters") }

          it "replays the stubbed response" do
            expect(response.code).to eql(202)
            expect(response.body).to eql("Omitted parameter stub body")
          end

        end

        context "and a request that does not match is made" do

          let(:response) { HTTParty.get("#{server_uri}/stub_with_omitted_parameters?key=must_be_omitted") }

          it "responds with a 404 status code" do
            expect(response.code).to eql(404)
          end

        end

      end

    end

    context "with a response delay" do

      before(:example) do
        configurer.stub_response!("/some_stub_path", method: :get, response: { delay_in_seconds: 2 })
      end

      it "delays to response by the time provided" do
        start_time = Time.now

        response = HTTParty.get("#{server_uri}/some_stub_path")

        expect(Time.now - start_time).to be >= 2.0
      end

    end

  end

end
