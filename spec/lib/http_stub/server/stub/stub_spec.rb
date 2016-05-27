describe HttpStub::Server::Stub::Stub do

  let(:request_header_payload) do
    {
        "header1" => "header_value1",
        "header2" => "header_value2",
        "header3" => "header_value3"
    }
  end
  let(:request_parameter_payload) do
    {
        "param1" => "param_value1",
        "param2" => "param_value2",
        "param3" => "param_value3"
    }
  end
  let(:request_method_payload) { "get" }
  let(:trigger_payload) do
    {
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
  let(:stub_id)      { SecureRandom.uuid }
  let(:stub_payload) do
    {
      "id" =>         stub_id,
      "uri" =>        "/a_path",
      "method" =>     stub_method,
      "headers" =>    request_header_payload,
      "parameters" => request_parameter_payload,
      "body" =>       { "schema" => { "json" => "stub schema definition" } },
      "response" => {
        "status" => 201,
        "body" =>   "Some body"
      },
      "triggers" => [ trigger_payload ]
    }
  end
  let(:stub_method)        { instance_double(HttpStub::Server::Stub::Match::Rule::Method, matches?: true) }
  let(:uri)                { instance_double(HttpStub::Server::Stub::Match::Rule::Uri, matches?: true) }
  let(:request_headers)    { instance_double(HttpStub::Server::Stub::Match::Rule::Headers, matches?: true) }
  let(:request_parameters) { instance_double(HttpStub::Server::Stub::Match::Rule::Parameters, matches?: true) }
  let(:request_body)       { double("HttpStub::Server::Stub::SomeRequestBody", matches?: true) }
  let(:response_types)     { [ HttpStub::Server::Stub::Response::Text, HttpStub::Server::Stub::Response::File ] }
  let(:response)           { instance_double(response_types.sample) }
  let(:triggers)           { instance_double(HttpStub::Server::Stub::Triggers) }

  let(:the_stub) { HttpStub::Server::Stub::Stub.new(stub_payload) }

  before(:example) do
    allow(HttpStub::Server::Stub::Match::Rule::Method).to receive(:new).and_return(stub_method)
    allow(HttpStub::Server::Stub::Match::Rule::Uri).to receive(:new).and_return(uri)
    allow(HttpStub::Server::Stub::Match::Rule::Headers).to receive(:new).and_return(request_headers)
    allow(HttpStub::Server::Stub::Match::Rule::Parameters).to receive(:new).and_return(request_parameters)
    allow(HttpStub::Server::Stub::Match::Rule::Body).to receive(:create).and_return(request_body)
    allow(HttpStub::Server::Stub::Response).to receive(:create).and_return(response)
    allow(HttpStub::Server::Stub::Triggers).to receive(:new).and_return(triggers)
  end

  describe "#matches?" do

    let(:logger) { instance_double(Logger) }

    context "when a request is provided" do

      let(:request_method) { request_method_payload }
      let(:request)        { instance_double(HttpStub::Server::Request::Request, method: request_method_payload) }

      subject { the_stub.matches?(request, logger) }

      describe "when the request uri matches" do

        before(:example) { allow(uri).to receive(:matches?).with(request, logger).and_return(true) }

        describe "and the request method matches" do

          describe "and a header match is configured" do

            describe "that matches" do

              before(:example) { allow(request_headers).to receive(:matches?).with(request, logger).and_return(true) }

              describe "and a parameter match is configured" do

                describe "that matches" do

                  before(:example) do
                    allow(request_parameters).to receive(:matches?).with(request, logger).and_return(true)
                  end

                  describe "and a body match is configured" do

                    describe "that matches" do

                      before(:example) do
                        allow(request_body).to receive(:matches?).with(request, logger).and_return(true)
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

        before(:example) { allow(uri).to receive(:matches?).with(request, logger).and_return(false) }

        it "returns false" do
          expect(subject).to be(false)
        end

      end

      describe "when the request method does not match" do

        before(:example) { allow(stub_method).to receive(:matches?).with(request, logger).and_return(false) }

        it "returns false" do
          expect(subject).to be(false)
        end

      end

      describe "when the headers do not match" do

        before(:example) { allow(request_headers).to receive(:matches?).with(request, logger).and_return(false) }

        it "returns false" do
          expect(subject).to be(false)
        end

      end

      describe "when the parameters do not match" do

        before(:example) { allow(request_parameters).to receive(:matches?).with(request, logger).and_return(false) }

        it "returns false" do
          expect(subject).to be(false)
        end

      end

      describe "when the bodies do not match" do

        before(:example) { allow(request_body).to receive(:matches?).with(request, logger).and_return(false) }

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

  describe "#repsonse_for" do

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

    it "returns the uri model encapsulating the uri provided in the request body" do
      expect(the_stub.uri).to eql(uri)
    end

  end

  describe "#method" do

    it "returns the method model encapsulating the method provided in the request body" do
      expect(the_stub.method).to eql(stub_method)
    end

  end

  describe "#headers" do

    it "returns the headers model encapsulating the headers provided in the request body" do
      expect(the_stub.headers).to eql(request_headers)
    end

  end

  describe "#parameters" do

    it "returns the parameters model encapsulating the parameters provided in the request body" do
      expect(the_stub.parameters).to eql(request_parameters)
    end

  end

  describe "#body" do

    it "returns the body model encapsulating the body provided in the request body" do
      expect(the_stub.body).to eql(request_body)
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

  describe "#stub_uri" do

    context "when an id is provided in the payload" do

      it "returns a relative uri to the stub that includes the id" do
        expect(the_stub.stub_uri).to eql("/http_stub/stubs/#{stub_id}")
      end

    end

    context "when an id is not provided in the payload" do

      it "returns a relative uri to the stub that includes a generated id" do
        expect(the_stub.stub_uri).to match(/\/http_stub\/stubs\/[a-zA-Z0-9-]+$/)
      end

    end

  end

  describe "#to_s" do

    it "returns a string representation of the stub arguments" do
      expect(stub_payload).to receive(:to_s).and_return("stub arguments string")

      expect(the_stub.to_s).to eql("stub arguments string")
    end

  end

end
