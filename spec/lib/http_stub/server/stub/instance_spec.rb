describe HttpStub::Server::Stub::Instance do

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
  let(:stub_payload) do
    {
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
  let(:stub_method)        { instance_double(HttpStub::Server::Stub::Method, match?: true) }
  let(:uri)                { instance_double(HttpStub::Server::Stub::Uri, match?: true) }
  let(:request_headers)    { instance_double(HttpStub::Server::Stub::RequestHeaders, match?: true) }
  let(:request_parameters) { instance_double(HttpStub::Server::Stub::RequestParameters, match?: true) }
  let(:request_body)       { double("HttpStub::Server::Stub::SomeRequestBody", match?: true) }
  let(:response)           { instance_double(HttpStub::Server::Stub::Response::Base) }
  let(:triggers)           { instance_double(HttpStub::Server::Stub::Triggers) }

  let(:the_stub) { HttpStub::Server::Stub::Instance.new(stub_payload) }

  before(:example) do
    allow(HttpStub::Server::Stub::Method).to receive(:new).and_return(stub_method)
    allow(HttpStub::Server::Stub::Uri).to receive(:new).and_return(uri)
    allow(HttpStub::Server::Stub::RequestHeaders).to receive(:new).and_return(request_headers)
    allow(HttpStub::Server::Stub::RequestParameters).to receive(:new).and_return(request_parameters)
    allow(HttpStub::Server::Stub::RequestBody).to receive(:create).and_return(request_body)
    allow(HttpStub::Server::Stub::Response).to receive(:create).and_return(response)
    allow(HttpStub::Server::Stub::Triggers).to receive(:new).and_return(triggers)
  end

  describe "#satisfies?" do

    let(:request_method) { request_method_payload }
    let(:request_uri)    { "/a_request_uri" }
    let(:request)        { instance_double(Rack::Request, :request_method => request_method_payload) }

    subject { the_stub.satisfies?(request) }

    describe "when the request uri matches" do

      before(:example) { allow(uri).to receive(:match?).with(request).and_return(true) }

      describe "and the request method matches" do

        describe "and a header match is configured" do

          describe "that matches" do

            before(:example) { allow(request_headers).to receive(:match?).with(request).and_return(true) }

            describe "and a parameter match is configured" do

              describe "that matches" do

                before(:example) { allow(request_parameters).to receive(:match?).with(request).and_return(true) }

                describe "and a body match is configured" do

                  describe "that matches" do

                    before(:example) { allow(request_body).to receive(:match?).with(request).and_return(true) }

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

      before(:example) { allow(uri).to receive(:match?).with(request).and_return(false) }

      it "returns false" do
        expect(subject).to be(false)
      end

    end

    describe "when the request method does not match" do

      before(:example) { allow(stub_method).to receive(:match?).with(request).and_return(false) }

      it "returns false" do
        expect(subject).to be(false)
      end

    end

    describe "when the headers do not match" do

      before(:example) { allow(request_headers).to receive(:match?).with(request).and_return(false) }

      it "returns false" do
        expect(subject).to be(false)
      end

    end

    describe "when the parameters do not match" do

      before(:example) { allow(request_parameters).to receive(:match?).with(request).and_return(false) }

      it "returns false" do
        expect(subject).to be(false)
      end

    end

    describe "when the bodies do not match" do

      before(:example) { allow(request_body).to receive(:match?).with(request).and_return(false) }

      it "returns false" do
        expect(subject).to be(false)
      end

    end

  end

  describe "#method" do

    it "returns the method model encapsulating the method provided in the request body" do
      expect(the_stub.method).to eql(stub_method)
    end

  end

  describe "#uri" do

    it "returns the rui model encapsulating the uri provided in the request body" do
      expect(the_stub.uri).to eql(uri)
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

  describe "#to_s" do

    it "returns a string representation of the stub arguments" do
      expect(stub_payload).to receive(:to_s).and_return("stub arguments string")

      expect(the_stub.to_s).to eql("stub arguments string")
    end

  end

end
