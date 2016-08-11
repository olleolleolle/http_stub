describe HttpStub::Server::Stub::Stub do

  let(:base_uri)        { "http://base.uri:8888" }
  let(:stub_id)         { SecureRandom.uuid }
  let(:trigger_payload) do
    {
      "base_uri" =>   base_uri,
      "uri" =>        "/a_triggered_path",
      "method" =>     "post",
      "headers" =>    { "triggered_header" => "triggered_header_value" },
      "parameters" => { "triggered_parameter" => "triggered_parameter_value" },
      "body" =>       { "schema" => { "json" => "trigger schema definition" } },
      "response" => {
        "status" => 203,
        "body" =>   "Triggered body"
      }
    }
  end
  let(:stub_payload) do
    {
      "id" =>         stub_id,
      "base_uri" =>   base_uri,
      "uri" =>        "/a_path",
      "method" =>     "get",
      "headers" =>    { "header" => "header value" },
      "parameters" => { "parameter" => "parameter value" },
      "body" =>       { "schema" => { "json" => "stub schema definition" } },
      "response" => {
        "status" => 201,
        "body" =>   "Some body"
      },
      "triggers" => [ trigger_payload ]
    }
  end
  let(:match_rules)        { instance_double(HttpStub::Server::Stub::Match::Rules, matches?: true) }
  let(:response_types)     { [ HttpStub::Server::Stub::Response::Text, HttpStub::Server::Stub::Response::File ] }
  let(:response)           { instance_double(response_types.sample) }
  let(:triggers)           { instance_double(HttpStub::Server::Stub::Triggers) }

  let(:the_stub) { HttpStub::Server::Stub::Stub.new(stub_payload) }

  before(:example) do
    allow(HttpStub::Server::Stub::Match::Rules).to receive(:new).and_return(match_rules)
    allow(HttpStub::Server::Stub::Response).to receive(:create).and_return(response)
    allow(HttpStub::Server::Stub::Triggers).to receive(:new).and_return(triggers)
  end

  describe "#matches?" do

    let(:logger) { instance_double(Logger) }

    context "when a request is provided" do

      let(:request_method) { request_method_payload }
      let(:request)        { instance_double(HttpStub::Server::Request::Request) }

      subject { the_stub.matches?(request, logger) }

      before(:example) { allow(match_rules).to receive(:matches?).with(request, logger).and_return(match_rules_result) }

      describe "and the match rules match the request" do

        let(:match_rules_result) { true }

        it "returns true" do
          expect(subject).to be(true)
        end

      end

      describe "and the match rule do not match the request" do

        let(:match_rules_result) { false }

        it "returns false" do
          expect(subject).to be(false)
        end

      end

    end

    context "when an id is provided" do

      subject { the_stub.matches?(id, logger) }

      context "and the id matches the stubs id" do

        let(:id) { stub_id }

        it "returns true" do
          expect(subject).to be(true)
        end

      end

      context "and the id does not match the stubs id" do

        let(:id) { "does-not-match" }

        it "returns false" do
          expect(subject).to be(false)
        end

      end

    end

  end

  describe "#response_for" do

    let(:request) { instance_double(HttpStub::Server::Request::Request) }

    subject { the_stub.response_for(request) }

    it "replaces values in the response with those from the request" do
      expect(response).to receive(:with_values_from).with(request)

      subject
    end

    it "returns the response with replaced values" do
      response_with_replaced_values = instance_double(response_types.sample)
      allow(response).to receive(:with_values_from).and_return(response_with_replaced_values)

      expect(subject).to eql(response_with_replaced_values)
    end

  end

  describe "#uri" do

    subject { the_stub.uri }

    context "when an id is provided in the payload" do

      it "returns a absolute uri on the server  that includes the id" do
        expect(subject).to eql("#{base_uri}/http_stub/stubs/#{stub_id}")
      end

    end

    context "when an id is not provided in the payload" do

      it "returns an absolute uri on the server that includes a generated id" do
        expect(subject).to match(%r{#{base_uri}/http_stub/stubs/[a-zA-Z0-9-]+$})
      end

    end

  end

  describe "#match_rules" do

    it "returns the match rules encapsulating the rules provided in the request body" do
      expect(the_stub.match_rules).to eql(match_rules)
    end

  end

  describe "#response" do

    it "exposes the response model encapsulating the response provided in the request body" do
      expect(the_stub.response).to eql(response)
    end

  end

  describe "#triggers" do

    it "returns the triggers model encapsulating the triggers provided in the request body" do
      expect(the_stub.triggers).to eql(triggers)
    end

  end

  describe "#to_json" do

    subject { the_stub.to_json }

    it "contains the stubs id" do
      expect(subject).to include_in_json(id: stub_id)
    end

    it "contains the stubs uri" do
      expect(subject).to include_in_json(uri: the_stub.uri)
    end

    it "contains the stubs match rules" do
      expect(subject).to include_in_json(match_rules: the_stub.match_rules)
    end

    it "contains the stubs response" do
      expect(subject).to include_in_json(response: the_stub.response)
    end

    it "contains the stubs triggers" do
      expect(subject).to include_in_json(triggers: the_stub.triggers)
    end

  end

  describe "#to_s" do

    it "returns a string representation of the stub arguments" do
      expect(stub_payload).to receive(:to_s).and_return("stub arguments string")

      expect(the_stub.to_s).to eql("stub arguments string")
    end

  end

end
