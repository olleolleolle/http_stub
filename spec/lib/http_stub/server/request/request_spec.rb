describe HttpStub::Server::Request::Request do

  let(:rack_path_info)      { "/rack/path/info" }
  let(:rack_request_method) { "some method" }
  let(:rack_env)            { { "some_env_name" => "some env value" } }
  let(:rack_parameters)     { { "some_parameter_name" => "some parameter value" } }
  let(:rack_body)           { "some request body" }
  let(:rack_request)        do
    instance_double(Rack::Request, path_info:      rack_path_info,
                                   request_method: rack_request_method,
                                   env:            rack_env,
                                   params:         rack_parameters,
                                   body:           StringIO.new(rack_body))
  end

  let(:server_request) { described_class.new(rack_request) }

  describe "#uri" do

    it "is the rack request path information" do
      expect(server_request.uri).to eql(rack_path_info)
    end

  end

  describe "#method" do

    subject { server_request.method }

    it "is the rack request method" do
      expect(subject).to eql(rack_request_method)
    end

  end

  describe "#headers" do

    subject { server_request.headers }

    it "creates http stub request headers from the rack request" do
      expect(HttpStub::Server::Request::Headers).to receive(:create).with(rack_request)

      subject
    end

    it "returns the created http stub request headers" do
      http_stub_request_headers = instance_double(HttpStub::Server::Request::Headers)
      allow(HttpStub::Server::Request::Headers).to receive(:create).and_return(http_stub_request_headers)

      expect(subject).to eql(http_stub_request_headers)
    end

  end

  describe "#parameters" do

    subject { server_request.parameters }

    it "creates http stub request parameters from the rack request" do
      expect(HttpStub::Server::Request::Parameters).to receive(:create).with(rack_request)

      subject
    end

    it "returns the created http stub request parameters" do
      http_stub_request_parameters = instance_double(HttpStub::Server::Request::Parameters)
      allow(HttpStub::Server::Request::Parameters).to receive(:create).and_return(http_stub_request_parameters)

      expect(subject).to eql(http_stub_request_parameters)
    end

  end

  describe "#body" do

    subject { server_request.body }

    it "is the read rack request body" do
      expect(subject).to eql(rack_body)
    end

  end

end
