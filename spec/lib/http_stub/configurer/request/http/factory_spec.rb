describe HttpStub::Configurer::Request::Http::Factory do

  describe "::multipart" do

    let(:model) { double("HttpStub::Configurer::Request::SomeModel") }
    let(:path)  { "some/model/path" }

    let(:multipart_request) { instance_double(HttpStub::Configurer::Request::Http::Multipart) }

    subject { described_class.multipart(path, model) }

    before(:example) do
      allow(HttpStub::Configurer::Request::Http::Multipart).to receive(:new).and_return(multipart_request)
    end

    it "creates a multipart request with the provided path" do
      expect(HttpStub::Configurer::Request::Http::Multipart).to receive(:new).with(hash_including(path: path))

      subject
    end

    it "creates a multipart request with the provided model" do
      expect(HttpStub::Configurer::Request::Http::Multipart).to receive(:new).with(hash_including(model: model))

      subject
    end

    context "when headers are provided" do

      let(:headers) { (1..3).each_with_object({}) { |i, result| result["header#{i}"] = "value#{i}" } }

      subject { described_class.multipart(path, model, headers) }

      it "creates a multipart request with the provided headers" do
        expect(HttpStub::Configurer::Request::Http::Multipart).to receive(:new).with(hash_including(headers: headers))

        subject
      end

    end

    context "when no headers are provided" do

      subject { described_class.multipart(path, model) }

      it "creates a multipart request with the empty headers" do
        expect(HttpStub::Configurer::Request::Http::Multipart).to receive(:new).with(hash_including(headers: {}))

        subject
      end

    end

    it "returns the created request" do
      expect(subject).to eql(multipart_request)
    end

  end

  describe "::get" do

    let(:path) { "/some/get/path" }

    let(:basic_request) { instance_double(HttpStub::Configurer::Request::Http::Basic) }

    subject { described_class.get(path) }

    before(:example) { allow(HttpStub::Configurer::Request::Http::Basic).to receive(:new).and_return(basic_request) }

    it "creates a basic GET request" do
      expect(HttpStub::Configurer::Request::Http::Basic).to receive(:new).with(hash_including(method: :get))

      subject
    end

    it "creates a basic request with the provided path" do
      expect(HttpStub::Configurer::Request::Http::Basic).to receive(:new).with(hash_including(path: path))

      subject
    end

    context "when headers are provided" do

      let(:headers) { (1..3).each_with_object({}) { |i, result| result["header#{i}"] = "value#{i}" } }

      subject { described_class.get(path, headers) }

      it "creates a basic request with the provided headers" do
        expect(HttpStub::Configurer::Request::Http::Basic).to receive(:new).with(hash_including(headers: headers))

        subject
      end

    end

    context "when no headers are provided" do

      subject { described_class.get(path) }

      it "creates a basic request with empty headers" do
        expect(HttpStub::Configurer::Request::Http::Basic).to receive(:new).with(hash_including(headers: {}))

        subject
      end

    end

    it "returns the created basic request" do
      expect(subject).to eql(basic_request)
    end

  end

  describe "::post" do

    let(:path) { "/some/post/path" }

    let(:basic_request) { instance_double(HttpStub::Configurer::Request::Http::Basic) }

    subject { described_class.post(path) }

    before(:example) { allow(HttpStub::Configurer::Request::Http::Basic).to receive(:new).and_return(basic_request) }

    it "creates a basic POST request" do
      expect(HttpStub::Configurer::Request::Http::Basic).to receive(:new).with(hash_including(method: :post))

      subject
    end

    it "creates a basic request with the provided path" do
      expect(HttpStub::Configurer::Request::Http::Basic).to receive(:new).with(hash_including(path: path))

      subject
    end

    context "when parameters are provided" do

      let(:parameters) { (1..3).each_with_object({}) { |i, result| result["parameter#{i}"] = "value#{i}" } }

      subject { described_class.post(path, parameters) }

      it "creates a basic request with the provided parameters" do
        expect(HttpStub::Configurer::Request::Http::Basic).to receive(:new).with(hash_including(parameters: parameters))

        subject
      end

    end

    context "when no parameters are provided" do

      subject { described_class.post(path) }

      it "creates a basic POST request with empty parameters" do
        allow(HttpStub::Configurer::Request::Http::Basic).to receive(:new).with(hash_including(parameters: {}))

        subject
      end

    end

    it "returns the created basic request" do
      expect(subject).to eql(basic_request)
    end

  end

  describe "::delete" do

    let(:path) { "/some/delete/path" }

    let(:basic_request) { instance_double(HttpStub::Configurer::Request::Http::Basic) }

    subject { described_class.delete(path) }

    before(:example) { allow(HttpStub::Configurer::Request::Http::Basic).to receive(:new).and_return(basic_request) }

    it "creates a basic DELETE request" do
      expect(HttpStub::Configurer::Request::Http::Basic).to receive(:new).with(hash_including(method: :delete))

      subject
    end

    it "creates a basic request with the provided path" do
      expect(HttpStub::Configurer::Request::Http::Basic).to receive(:new).with(hash_including(path: path))

      subject
    end

    context "when headers are provided" do

      let(:headers) { (1..3).each_with_object({}) { |i, result| result["header#{i}"] = "value#{i}" } }

      subject { described_class.delete(path, headers) }

      it "creates a basic request with the provided headers" do
        expect(HttpStub::Configurer::Request::Http::Basic).to receive(:new).with(hash_including(headers: headers))

        subject
      end

    end

    context "when no headers are provided" do

      subject { described_class.delete(path) }

      it "creates a basic request with empty headers" do
        expect(HttpStub::Configurer::Request::Http::Basic).to receive(:new).with(hash_including(headers: {}))

        subject
      end

    end

    it "returns the created basic request" do
      expect(subject).to eql(basic_request)
    end

  end

end
