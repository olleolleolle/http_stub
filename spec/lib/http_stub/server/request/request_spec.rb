describe HttpStub::Server::Request::Request do

  let(:sinatra_base_uri)       { "http://base_url:8888" }
  let(:sinatra_uri)            { "/rack/path/info" }
  let(:sinatra_request_method) { "some method" }
  let(:sinatra_headers)        { { "some_header" => "some header value" } }
  let(:sinatra_parameters)     { { "some_parameter" => "some parameter value" } }
  let(:sinatra_body)           { "some request body" }
  let(:sinatra_request)        do
    instance_double(HttpStub::Server::Request::SinatraRequest, base_uri: sinatra_base_uri,
                    uri:                                                 sinatra_uri,
                    method:                                              sinatra_request_method,
                    headers:                                             sinatra_headers,
                    parameters:                                          sinatra_parameters,
                    body:                                                sinatra_body)
  end
  let(:session_id)             { "some session id" }
  let(:session)                { instance_double(HttpStub::Server::Session::Session) }

  let(:server_request) { described_class.new(sinatra_request, session_id, session) }

  describe "#base_uri" do

    subject { server_request.base_uri }

    it "is the sinatra requests base uri" do
      expect(subject).to eql(sinatra_base_uri)
    end

  end

  describe "#uri" do

    subject { server_request.uri }

    it "is the sinatra requests uri" do
      expect(subject).to eql(sinatra_uri)
    end

  end

  describe "#method" do

    subject { server_request.method }

    it "is the sinatra requests method" do
      expect(subject).to eql(sinatra_request_method)
    end

  end

  describe "#headers" do

    subject { server_request.headers }

    it "is the sinatra requests headers" do
      expect(subject).to eql(sinatra_headers)

      subject
    end

  end

  describe "#parameters" do

    subject { server_request.parameters }

    it "is the sinatra requests parameters" do
      expect(subject).to eql(sinatra_parameters)

      subject
    end

  end

  describe "#body" do

    subject { server_request.body }

    it "is the sinatra requests body" do
      expect(subject).to eql(sinatra_body)
    end

  end

  describe "#to_json" do

    let(:sinatra_request_json) { "some json" }

    subject { server_request.to_json }

    before(:example) { allow(sinatra_request).to receive(:to_json).and_return(sinatra_request_json) }

    it "returns the sinatra requests json representation" do
      expect(subject).to eql(sinatra_request_json)
    end

  end

  describe "#session_id" do

    subject { server_request.session_id }

    it "is the provided id" do
      expect(subject).to eql(session_id)
    end

  end

  describe "#session" do

    subject { server_request.session }

    it "is the provided session" do
      expect(subject).to eql(session)
    end

  end

end
