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

  describe "::scenario" do

    let(:model)             { instance_double(HttpStub::Configurer::Request::Scenario) }
    let(:multipart_request) { instance_double(HttpStub::Configurer::Request::Http::Multipart) }

    subject { HttpStub::Configurer::Request::Http::Factory.scenario(model) }

    before(:example) do
      allow(HttpStub::Configurer::Request::Http::Multipart).to receive(:new).and_return(multipart_request)
    end

    it "creates a multipart request for the stub scenarios endpoint with the provided model" do
      expect(HttpStub::Configurer::Request::Http::Multipart).to receive(:new).with("/stubs/scenarios", model)

      subject
    end

    it "returns the created request" do
      expect(subject).to eql(multipart_request)
    end

  end

  describe "::activate" do

    let(:uri)           { "some/activate/uri" }
    let(:basic_request) { instance_double(HttpStub::Configurer::Request::Http::Basic) }

    subject { HttpStub::Configurer::Request::Http::Factory.activate(uri) }

    before(:example) do
      allow(HttpStub::Configurer::Request::Http::Factory).to receive(:get).and_return(basic_request)
    end

    context "when the uri is not prefixed with '/'" do

      let(:uri) { "uri/not/prefixed/with/forward/slash" }

      it "creates a get request with the uri prefixed with '/'" do
        expect(HttpStub::Configurer::Request::Http::Factory).to receive(:get).with("/#{uri}")

        subject
      end

    end

    context "when the uri is prefixed with '/'" do

      let(:uri) { "/uri/prefixed/with/forward/slash" }

      it "creates a get request with the provided uri" do
        expect(HttpStub::Configurer::Request::Http::Factory).to receive(:get).with(uri)

        subject
      end

    end

    it "returns the created request" do
      expect(subject).to eql(basic_request)
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
