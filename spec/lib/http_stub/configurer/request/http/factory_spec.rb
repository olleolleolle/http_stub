describe HttpStub::Configurer::Request::Http::Factory do

  describe "::multipart" do

    let(:model)             { double("HttpStub::Configurer::Request::SomeModel") }
    let(:multipart_request) { instance_double(HttpStub::Configurer::Request::Http::Multipart) }

    subject { HttpStub::Configurer::Request::Http::Factory.multipart(model) }

    before(:example) do
      allow(HttpStub::Configurer::Request::Http::Multipart).to receive(:new).and_return(multipart_request)
    end

    it "creates a multipart request with the provided model" do
      expect(HttpStub::Configurer::Request::Http::Multipart).to receive(:new).with(model)

      subject
    end

    it "returns the created request" do
      expect(subject).to eql(multipart_request)
    end

  end

  describe "::get" do

    let(:path)          { "/some/get/path" }
    let(:parameters)    { {} }
    let(:get_request)   { instance_double(Net::HTTP::Get) }
    let(:basic_request) { instance_double(HttpStub::Configurer::Request::Http::Basic) }

    subject { HttpStub::Configurer::Request::Http::Factory.get(path, parameters) }

    before(:example) do
      allow(Net::HTTP::Get).to receive(:new).and_return(get_request)
      allow(HttpStub::Configurer::Request::Http::Basic).to receive(:new).and_return(basic_request)
    end

    context "when the path is absolute" do

      let(:path) { "/some/absolute/get/path" }

      it "creates a GET request with the provided path" do
        expect(Net::HTTP::Get).to receive(:new).with(path)

        subject
      end

    end

    context "when the path is relative" do

      let(:path) { "some/relative/get/path" }

      it "creates a GET request with the path prefixed by '/'" do
        expect(Net::HTTP::Get).to receive(:new).with("/#{path}")

        subject
      end

    end

    context "when no parameters are provided" do

      subject { HttpStub::Configurer::Request::Http::Factory.get(path) }

      it "creates a GET request with the provided path" do
        expect(Net::HTTP::Get).to receive(:new).with(path)

        subject
      end

    end

    context "when parameters are provided" do

      let(:parameters) { (1..3).each_with_object({}) { |i, result| result["key#{i}"] = "value#{i}" } }

      it "creates a GET request for a URL starting with the provided path" do
        expect(Net::HTTP::Get).to receive(:new).with(a_string_starting_with(path))

        subject
      end

      it "creates a GET request for a URL containing the parameters" do
        expected_parameters = parameters.map { |key, value| "#{key}=#{value}" }.join("&")
        expect(Net::HTTP::Get).to receive(:new).with(a_string_ending_with("?#{expected_parameters}"))

        subject
      end

    end

    context "when parameters are provided containing values that require url encoding" do

      let(:parameters) do
        {
          "key=1" => "value=1",
          "key&2" => "value&2",
          "key?3" => "value?3"
        }
      end

      it "creates a GET request for a URL containing the encoded parameters" do
        expected_parameters = "key%3D1=value%3D1&key%262=value%262&key%3F3=value%3F3"
        expect(Net::HTTP::Get).to receive(:new).with(a_string_ending_with("?#{expected_parameters}"))

        subject
      end

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

    let(:path)          { "/some/post/path" }
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

    let(:path)           { "/some/delete/path" }
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
