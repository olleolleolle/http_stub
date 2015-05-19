describe HttpStub::Configurer::Request::Http::Factory do

  describe "::stub" do

    let(:model)             { instance_double(HttpStub::Configurer::Request::Stub) }
    let(:multipart_request) { instance_double(HttpStub::Configurer::Request::Http::Multipart) }

    subject { HttpStub::Configurer::Request::Http::Factory.stub(model) }

    before(:example) do
      allow(HttpStub::Configurer::Request::Http::Multipart).to receive(:new).and_return(multipart_request)
    end

    it "creates a multipart request for the stubs endpoint with the provided model" do
      expect(HttpStub::Configurer::Request::Http::Multipart).to receive(:new).with("/stubs", model)

      subject
    end

    it "returns the created request" do
      expect(subject).to eql(multipart_request)
    end

  end

  describe "::stub_activator" do

    let(:model)             { instance_double(HttpStub::Configurer::Request::StubActivator) }
    let(:multipart_request) { instance_double(HttpStub::Configurer::Request::Http::Multipart) }

    subject { HttpStub::Configurer::Request::Http::Factory.stub_activator(model) }

    before(:example) do
      allow(HttpStub::Configurer::Request::Http::Multipart).to receive(:new).and_return(multipart_request)
    end

    it "creates a multipart request for the stub activators endpoint with the provided model" do
      expect(HttpStub::Configurer::Request::Http::Multipart).to receive(:new).with("/stubs/activators", model)

      subject
    end

    it "returns the created request" do
      expect(subject).to eql(multipart_request)
    end

  end

  describe "::get" do

    let(:path)          { "some/get/path" }
    let(:get_request)   { instance_double(Net::HTTP::Get) }
    let(:basic_request) { instance_double(HttpStub::Configurer::Request::Http::Basic) }

    subject { HttpStub::Configurer::Request::Http::Factory.get(path) }

    before(:example) do
      allow(Net::HTTP::Get).to receive(:new).and_return(get_request)
      allow(HttpStub::Configurer::Request::Http::Basic).to receive(:new).and_return(basic_request)
    end

    it "creates a GET request with the provided path" do
      expect(Net::HTTP::Get).to receive(:new).with(path)

      subject
    end

    it "creates a basic request wrapping the GET request" do
      expect(HttpStub::Configurer::Request::Http::Basic).to receive(:new).with(get_request)

      subject
    end

    it "returns the created basic request" do
      expect(subject).to eql(basic_request)
    end

  end

  describe "::post" do

    let(:path)          { "some/post/path" }
    let(:post_request)  { instance_double(Net::HTTP::Post).as_null_object }
    let(:basic_request) { instance_double(HttpStub::Configurer::Request::Http::Basic) }

    subject { HttpStub::Configurer::Request::Http::Factory.post(path) }

    before(:example) do
      allow(Net::HTTP::Post).to receive(:new).and_return(post_request)
      allow(HttpStub::Configurer::Request::Http::Basic).to receive(:new).and_return(basic_request)
    end

    it "creates a POST request with the provided path" do
      expect(Net::HTTP::Post).to receive(:new).with(path)

      subject
    end

    it "establishes an empty body in the POST request" do
      expect(post_request).to receive(:body=).with("")

      subject
    end

    it "creates a basic request wrapping the POST request" do
      expect(HttpStub::Configurer::Request::Http::Basic).to receive(:new).with(post_request)

      subject
    end

    it "returns the created basic request" do
      expect(subject).to eql(basic_request)
    end

  end

  describe "::delete" do

    let(:path)           { "some/get/path" }
    let(:delete_request) { instance_double(Net::HTTP::Delete) }
    let(:basic_request)  { instance_double(HttpStub::Configurer::Request::Http::Basic) }

    subject { HttpStub::Configurer::Request::Http::Factory.delete(path) }

    before(:example) do
      allow(Net::HTTP::Delete).to receive(:new).and_return(delete_request)
      allow(HttpStub::Configurer::Request::Http::Basic).to receive(:new).and_return(basic_request)
    end

    it "creates a DELETE request with the provided path" do
      expect(Net::HTTP::Delete).to receive(:new).with(path)

      subject
    end

    it "creates a basic request wrapping the DELETE request" do
      expect(HttpStub::Configurer::Request::Http::Basic).to receive(:new).with(delete_request)

      subject
    end

    it "returns the created basic request" do
      expect(subject).to eql(basic_request)
    end

  end

end
