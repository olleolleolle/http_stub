describe HttpStub::Server::Request do

  let(:rack_path_info)      { "/rack/path/info" }
  let(:rack_request_method) { "some method" }
  let(:rack_parameters)     { { "parameter_key" => "parameter value" } }
  let(:rack_body)           { "some request body" }
  let(:rack_request)        do
    instance_double(Rack::Request, path_info:      rack_path_info,
                                   request_method: rack_request_method,
                                   params:         rack_parameters,
                                   body:           StringIO.new(rack_body))
  end

  let(:server_request) { described_class.new(rack_request) }

  before(:example) do
    allow(HttpStub::Server::HeaderParser).to receive(:parse).and_return({})
    allow(HttpStub::Server::FormattedHash).to receive(:new)
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

    let(:parsed_headers) { { "parsed_header_key" => "parsed header value" } }
    let(:formatted_hash) { instance_double(HttpStub::Server::FormattedHash) }

    subject { server_request.headers }

    before(:example) do
      allow(HttpStub::Server::HeaderParser).to receive(:parse).and_return(parsed_headers)
      allow(HttpStub::Server::FormattedHash).to receive(:new).with(parsed_headers, anything).and_return(formatted_hash)
    end

    it "parses the headers from the rack request via the header parser" do
      expect(HttpStub::Server::HeaderParser).to receive(:parse).with(rack_request)

      subject
    end

    it "creates a formatted hash containing the parsed headers" do
      expect(HttpStub::Server::FormattedHash).to receive(:new).with(parsed_headers, anything)

      subject
    end

    it "creates a formatted hash formatted by a ':' request value delimiter" do
      expect(HttpStub::Server::FormattedHash).to receive(:new).with(anything, ":")

      subject
    end

    it "is the formattted hash" do
      expect(subject).to eql(formatted_hash)
    end

  end

  describe "#parameters" do

    let(:formatted_hash) { instance_double(HttpStub::Server::FormattedHash) }

    subject { server_request.parameters }

    before(:example) do
      allow(HttpStub::Server::FormattedHash).to receive(:new).with(rack_parameters, anything).and_return(formatted_hash)
    end

    it "creates a formatted hash containing the rack request parameters" do
      expect(HttpStub::Server::FormattedHash).to receive(:new).with(rack_parameters, anything)

      subject
    end

    it "creates a formatted hash with a '=' request value delimiter" do
      expect(HttpStub::Server::FormattedHash).to receive(:new).with(anything, "=")

      subject
    end

    it "is the formatted hash" do
      expect(subject).to eql(formatted_hash)
    end

  end

  describe "#body" do

    subject { server_request.body }

    it "is the read rack request body" do
      expect(subject).to eql(rack_body)
    end

  end

end
