describe HttpStub::Server::Stub do

  let(:raw_stub_headers) do
    {
        "header1" => "header_value1",
        "header2" => "header_value2",
        "header3" => "header_value3"
    }
  end
  let(:raw_stub_parameters) do
    {
        "param1" => "param_value1",
        "param2" => "param_value2",
        "param3" => "param_value3"
    }
  end
  let(:stub_method) { "get" }
  let(:stub_trigger) do
    {
      "uri" =>        "/a_triggered_path",
      "method" =>     "post",
      "headers" =>    { "triggered_header" => "triggered_header_value" },
      "parameters" => { "triggered_parameter" => "triggered_parameter_value" },
      "response" => {
        "status" => 203,
        "body" =>   "Triggered body"
      }
    }
  end
  let(:stub_args) do
    {
      "uri" =>        "/a_path",
      "method" =>     stub_method,
      "headers" =>    raw_stub_headers,
      "parameters" => raw_stub_parameters,
      "response" => {
        "status" => 201,
        "body" =>   "Some body"
      },
      "triggers" => [ stub_trigger ]
    }
  end
  let(:stub_uri)        { instance_double(HttpStub::Server::StubUri, match?: true) }
  let(:stub_headers)    { instance_double(HttpStub::Server::StubHeaders, match?: true) }
  let(:stub_parameters) { instance_double(HttpStub::Server::StubParameters, match?: true) }
  let(:stub_response)   { instance_double(HttpStub::Server::StubResponse::Base, clear: nil) }
  let(:stub_triggers)   { instance_double(HttpStub::Server::StubTriggers, clear: nil) }

  let(:the_stub) { HttpStub::Server::Stub.new(stub_args) }

  before(:example) do
    allow(HttpStub::Server::StubUri).to receive(:new).and_return(stub_uri)
    allow(HttpStub::Server::StubHeaders).to receive(:new).and_return(stub_headers)
    allow(HttpStub::Server::StubParameters).to receive(:new).and_return(stub_parameters)
    allow(HttpStub::Server::StubResponse).to receive(:create).and_return(stub_response)
    allow(HttpStub::Server::StubTriggers).to receive(:new).and_return(stub_triggers)
  end

  describe "#satisfies?" do

    let(:request_uri)    { "/a_request_uri" }
    let(:request_method) { stub_method }
    let(:request)        { instance_double(Rack::Request, :request_method => request_method) }

    describe "when the request uri matches" do

      before(:example) { allow(stub_uri).to receive(:match?).with(request).and_return(true) }

      describe "and the request method matches" do

        describe "and a header match is configured" do

          describe "that matches" do

            before(:example) { allow(stub_headers).to receive(:match?).with(request).and_return(true) }

            describe "and a parameter match is configured" do

              describe "that matches" do

                before(:example) { allow(stub_parameters).to receive(:match?).with(request).and_return(true) }

                it "returns true" do
                  expect(the_stub.satisfies?(request)).to be_truthy
                end

              end

            end

          end

        end

      end

    end

    describe "when the request uri does not match" do

      before(:example) { allow(stub_uri).to receive(:match?).with(request).and_return(false) }

      it "returns false" do
        expect(the_stub.satisfies?(request)).to be_falsey
      end

    end

    describe "when the request method does not match" do

      let(:request_method) { "post" }

      it "returns false" do
        expect(the_stub.satisfies?(request)).to be_falsey
      end

    end

    describe "when the headers do not match" do

      before(:example) { allow(stub_headers).to receive(:match?).with(request).and_return(false) }

      it "returns false" do
        expect(the_stub.satisfies?(request)).to be_falsey
      end

    end

    describe "when the parameters do not match" do

      before(:example) { allow(stub_parameters).to receive(:match?).with(request).and_return(false) }

      it "returns false" do
        expect(the_stub.satisfies?(request)).to be_falsey
      end

    end

  end

  describe "#uri" do

    it "returns the parameters model encapsulating the uri provided in the request body" do
      expect(the_stub.uri).to eql(stub_uri)
    end

  end

  describe "#method" do

    it "returns the value provided in the request body" do
      expect(the_stub.method).to eql(stub_method)
    end

  end

  describe "#headers" do

    it "returns the headers model encapsulating the headers provided in the request body" do
      expect(the_stub.headers).to eql(stub_headers)
    end

  end

  describe "#parameters" do

    it "returns the parameters model encapsulating the parameters provided in the request body" do
      expect(the_stub.parameters).to eql(stub_parameters)
    end

  end

  describe "#response" do

    it "exposes the response model encapsulating the response provided in the request body" do
      expect(the_stub.response).to eql(stub_response)
    end

  end

  describe "#triggers" do

    it "returns the triggers model encapsulating the triggers provided in the request body" do
      expect(the_stub.triggers).to eql(stub_triggers)
    end

  end

  describe "#clear" do

    subject { the_stub.clear }

    it "clears the stub response" do
      expect(stub_response).to receive(:clear)

      subject
    end

    it "clears the stub triggers" do
      expect(stub_triggers).to receive(:clear)

      subject
    end

  end

  describe "#to_s" do

    it "returns a string representation of the stub arguments" do
      expect(stub_args).to receive(:to_s).and_return("stub arguments string")

      expect(the_stub.to_s).to eql("stub arguments string")
    end

  end

end
