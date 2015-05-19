describe HttpStub::Server::StubResponse::Base do

  let(:status)           { 202 }
  let(:headers)          { nil }
  let(:body)             { "A response body" }
  let(:delay_in_seconds) { 18 }
  let(:args) do
    { "status" => status, "headers" => headers, "body" => body, "delay_in_seconds" => delay_in_seconds }
  end

  let(:testable_response_class) { Class.new(HttpStub::Server::StubResponse::Base) }

  let(:response) { testable_response_class.new(args) }

  describe "#status" do

    context "when a value is provided in the arguments" do

      context "that is an integer" do

        it "returns the value provided" do
          expect(response.status).to eql(status)
        end

      end

      context "that is an empty string" do

        let(:status) { "" }

        it "defaults to 200" do
          expect(response.status).to eql(200)
        end

      end

    end

    context "when the status is not provided in the arguments" do

      let(:args) { { "body" => body, "delay_in_seconds" => delay_in_seconds } }

      it "defaults to 200" do
        expect(response.status).to eql(200)
      end

    end

  end

  describe "#body" do

    it "returns the value provided in the arguments" do
      expect(response.body).to eql("A response body")
    end

  end

  describe "#delay_in_seconds" do

    context "when a value is provided in the arguments" do

      context "that is an integer" do

        it "returns the value" do
          expect(response.delay_in_seconds).to eql(delay_in_seconds)
        end

      end

      context "that is an empty string" do

        let(:delay_in_seconds) { "" }

        it "defaults to 0" do
          expect(response.delay_in_seconds).to eql(0)
        end

      end

    end

    context "when a value is not provided in the arguments" do

      let(:args) { { "status" => status, "body" => body } }

      it "defaults to 0" do
        expect(response.delay_in_seconds).to eql(0)
      end

    end

  end

  describe "#headers" do

    let(:response_header_hash) { response.headers.to_hash }

    it "is Headers" do
      expect(response.headers).to be_a(HttpStub::Server::Headers)
    end

    context "when default headers have been added" do

      let(:default_headers) do
        { "a_default_header" => "a default value", "another_default_header" => "some other default value" }
      end

      before(:example) { testable_response_class.add_default_headers(default_headers) }

      context "and headers are provided" do

        context "that have some names matching the defaults" do

          let(:headers) { { "a_default_header" => "an overridde value" } }

          it "replaces the matching default values with those provided" do
            expect(response_header_hash["a_default_header"]).to eql("an overridde value")
          end

          it "preserves the default values that do not match" do
            expect(response_header_hash["another_default_header"]).to eql("some other default value")
          end

        end

        context "that do not have names matching the defaults" do

          let(:headers) do
            {
              "a_header" => "some header",
              "another_header" => "another value",
              "yet_another_header" => "yet another value"
            }
          end

          it "returns the defaults headers combined with the provided headers" do
            expect(response_header_hash).to eql(default_headers.merge(headers))
          end

        end

      end

      context "and no headers are provided" do

        it "returns the default headers" do
          expect(response_header_hash).to eql(default_headers)
        end

      end

    end

    context "when no default headers have been added" do

      context "and headers are provided" do

        let(:headers) do
          {
            "a_header" => "some header",
            "another_header" => "another value",
            "yet_another_header" => "yet another value"
          }
        end

        it "returns the headers" do
          expect(response_header_hash).to eql(headers)
        end

      end

      context "and no headers are provided" do

        let(:headers) { nil }

        it "returns an empty hash" do
          expect(response_header_hash).to eql({})
        end

      end

    end

  end

  describe "#empty?" do

    context "when the response is EMPTY" do

      let(:response) { HttpStub::Server::Response::EMPTY }

      it "returns true" do
        expect(response).to be_empty
      end

    end

    context "when the response is not EMPTY" do

      it "returns false" do
        expect(response).not_to be_empty
      end

    end

  end

  describe "#clear" do

    it "executes without error" do
      expect { response.clear }.to_not raise_error
    end

  end

  describe "#to_s" do

    it "returns the string representation of the provided arguments" do
      expect(response.to_s).to eql(args.to_s)
    end

  end

end
