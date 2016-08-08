describe HttpStub::Server::Stub::Match::Rules do

  let(:header_payload) do
    {
        "match_rule_header1" => "match_rule_header_value1",
        "match_rule_header2" => "match_rule_header_value2",
        "match_rule_header3" => "match_rule_header_value3"
    }
  end
  let(:parameter_payload) do
    {
        "match_rule_parameter1" => "match_rule_parameter_value1",
        "match_rule_parameter2" => "match_rule_parameter_value2",
        "match_rule_parameter3" => "match_rule_parameter_value3"
    }
  end
  let(:method_payload) { "get" }
  let(:match_rules_payload) do
    {
      "uri" =>        "/a_path",
      "method" =>     method_payload,
      "headers" =>    header_payload,
      "parameters" => parameter_payload,
      "body" =>       { "schema" => { "json" => "stub schema definition" } }
    }
  end
  let(:uri_rule)        { instance_double(HttpStub::Server::Stub::Match::Rule::Uri, matches?: true) }
  let(:method_rule)     { instance_double(HttpStub::Server::Stub::Match::Rule::Method, matches?: true) }
  let(:headers_rule)    { instance_double(HttpStub::Server::Stub::Match::Rule::Headers, matches?: true) }
  let(:parameters_rule) { instance_double(HttpStub::Server::Stub::Match::Rule::Parameters, matches?: true) }
  let(:body_rule)       { double("HttpStub::Server::Stub::SomeRequestBody", matches?: true) }

  let(:match_rules) { HttpStub::Server::Stub::Match::Rules.new(match_rules_payload) }

  before(:example) do
    allow(HttpStub::Server::Stub::Match::Rule::Uri).to receive(:new).and_return(uri_rule)
    allow(HttpStub::Server::Stub::Match::Rule::Method).to receive(:new).and_return(method_rule)
    allow(HttpStub::Server::Stub::Match::Rule::Headers).to receive(:new).and_return(headers_rule)
    allow(HttpStub::Server::Stub::Match::Rule::Parameters).to receive(:new).and_return(parameters_rule)
    allow(HttpStub::Server::Stub::Match::Rule::Body).to receive(:create).and_return(body_rule)
  end

  describe "::EMPTY" do

    subject { HttpStub::Server::Stub::Match::Rules::EMPTY }

    it "has an empty uri rule" do
      expect(subject.uri.to_s).to eql("")
    end

    it "has an empty method rule" do
      expect(subject.method.to_s).to eql("")
    end

    it "has an empty headers rule" do
      expect(subject.headers.to_hash).to eql({})
    end

    it "has an empty parameters rule" do
      expect(subject.parameters.to_hash).to eql({})
    end

    it "has an empty body rule" do
      expect(subject.body.to_s).to eql("")
    end

  end

  describe "#matches?" do

    let(:request_method) { method_payload }
    let(:request)        { instance_double(HttpStub::Server::Request::Request, method: method_payload) }
    let(:logger)         { instance_double(Logger) }

    subject { match_rules.matches?(request, logger) }

    describe "when the request uri matches" do

      before(:example) { allow(uri_rule).to receive(:matches?).with(request, logger).and_return(true) }

      describe "and the request method matches" do

        describe "and a headers rule is configured" do

          describe "that matches" do

            before(:example) { allow(headers_rule).to receive(:matches?).with(request, logger).and_return(true) }

            describe "and a parameters rule is configured" do

              describe "that matches" do

                before(:example) do
                  allow(parameters_rule).to receive(:matches?).with(request, logger).and_return(true)
                end

                describe "and a body rule is configured" do

                  describe "that matches" do

                    before(:example) do
                      allow(body_rule).to receive(:matches?).with(request, logger).and_return(true)
                    end

                    it "returns true" do
                      expect(subject).to be(true)
                    end

                  end

                end

              end

            end

          end

        end

      end

    end

    describe "when the request uri does not match" do

      before(:example) { allow(uri_rule).to receive(:matches?).with(request, logger).and_return(false) }

      it "returns false" do
        expect(subject).to be(false)
      end

    end

    describe "when the request method does not match" do

      before(:example) { allow(method_rule).to receive(:matches?).with(request, logger).and_return(false) }

      it "returns false" do
        expect(subject).to be(false)
      end

    end

    describe "when the headers do not match" do

      before(:example) { allow(headers_rule).to receive(:matches?).with(request, logger).and_return(false) }

      it "returns false" do
        expect(subject).to be(false)
      end

    end

    describe "when the parameters do not match" do

      before(:example) { allow(parameters_rule).to receive(:matches?).with(request, logger).and_return(false) }

      it "returns false" do
        expect(subject).to be(false)
      end

    end

    describe "when the bodies do not match" do

      before(:example) { allow(body_rule).to receive(:matches?).with(request, logger).and_return(false) }

      it "returns false" do
        expect(subject).to be(false)
      end

    end

  end

  describe "#uri" do

    it "returns the uri rule for the uri provided in the request body" do
      expect(match_rules.uri).to eql(uri_rule)
    end

  end

  describe "#method" do

    it "returns the method rule for the method provided in the request body" do
      expect(match_rules.method).to eql(method_rule)
    end

  end

  describe "#headers" do

    it "returns the headers rule for the headers provided in the request body" do
      expect(match_rules.headers).to eql(headers_rule)
    end

  end

  describe "#parameters" do

    it "returns the parameters rule for the parameters provided in the request body" do
      expect(match_rules.parameters).to eql(parameters_rule)
    end

  end

  describe "#body" do

    it "returns the body rule for the body provided in the request body" do
      expect(match_rules.body).to eql(body_rule)
    end

  end

  describe "#to_hash" do

    subject { match_rules.to_hash }

    describe "supporting creating a JSON representation of the stub" do

      it "contains the rules uri" do
        expect(subject).to include(uri: match_rules.uri)
      end

      it "contains the rules method" do
        expect(subject).to include(method: match_rules.method)
      end

      it "contains the rules headers" do
        expect(subject).to include(headers: match_rules.headers)
      end

      it "contains the rules parameters" do
        expect(subject).to include(parameters: match_rules.parameters)
      end

      it "contains the rules body" do
        expect(subject).to include(body: match_rules.body)
      end

    end

  end

end
