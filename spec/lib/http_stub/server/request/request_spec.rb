describe HttpStub::Server::Request::Request do

  let(:rack_base_url)       { "http://base_url:8888" }
  let(:rack_path_info)      { "/rack/path/info" }
  let(:rack_request_method) { "some method" }
  let(:rack_env)            { { "some_env_name" => "some env value" } }
  let(:rack_parameters)     { { "some_parameter_name" => "some parameter value" } }
  let(:rack_body)           { "some request body" }
  let(:rack_request)        do
    instance_double(Rack::Request, base_url:       rack_base_url,
                                   path_info:      rack_path_info,
                                   request_method: rack_request_method,
                                   env:            rack_env,
                                   params:         rack_parameters,
                                   body:           StringIO.new(rack_body))
  end

  let(:server_request) { described_class.new(rack_request) }

  describe "#base_uri" do

    it "is the rack base url" do
      expect(server_request.base_uri).to eql(rack_base_url)
    end

  end

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

  describe "#to_json" do

    subject { server_request.to_json }

    it "contains the requests uri" do
      expect(subject).to include_in_json(uri: server_request.uri)
    end

    it "contains the requests method" do
      expect(subject).to include_in_json(method: server_request.method)
    end

    it "contains the requests headers" do
      expect(subject).to include_in_json(headers: server_request.headers)
    end

    it "contains the requests parameters" do
      expect(subject).to include_in_json(parameters: server_request.parameters)
    end

    it "contains the requests body" do
      expect(subject).to include_in_json(body: server_request.body)
    end

  end

end
