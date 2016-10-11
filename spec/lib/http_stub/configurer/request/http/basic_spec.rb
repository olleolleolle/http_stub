describe HttpStub::Configurer::Request::Http::Basic do

  let(:request_method) { :get }
  let(:path)           { "some/path" }
  let(:args)           { { method: request_method, path: path } }

  let(:basic_request) { described_class.new(args) }

  describe "#to_http_request" do

    subject { basic_request.to_http_request }

    it "returns a HTTP request of the provided type" do
      expect(subject).to be_a(Net::HTTP::Get)
    end

    it "returns a request with the provided path prefixed with http_stub scoping" do
      expect(subject.path).to eql("/http_stub/#{path}")
    end

    context "when headers are provided" do

      let(:args) { { method: request_method, path: path, headers: headers } }

      context "whose names are symbols" do

        let(:headers) { (1..3).each_with_object({}) { |i, result| result["header#{i}".to_sym] = "value#{i}" } }

        it "returns a request with the provided headers with names converted to strings" do
          expect(request_headers).to include(headers.stringify_keys)
        end

      end

      context "whose names are strings" do

        let(:headers) { (1..3).each_with_object({}) { |i, result| result["header#{i}"] = "value#{i}" } }

        it "returns a request with the provided headers" do
          expect(request_headers).to include(headers)
        end

      end

    end

    context "when headers are not provided" do

      it "returns a request with default headers" do
        expect(request_headers).to_not be_empty
      end

    end

    context "when parameters are provided" do

      let(:parameters) { (1..3).each_with_object({}) { |i, result| result["parameter#{i}"] = "value#{i}" } }

      let(:args) { { method: request_method, path: path, parameters: parameters } }

      it "returns a request with the provided parameters" do
        expect(request_parameters).to eql(parameters)
      end

    end

    context "when parameters are not provided" do

      let(:args) { { method: request_method, path: path } }

      it "returns a request without parameters" do
        expect(subject.body).to eql(nil)
      end

    end

    it "returns a request with the provided path prefixed with http_stub scoping" do
      expect(subject.path).to eql("/http_stub/#{path}")
    end

  end

  def request_headers
    subject.to_hash.each_with_object({}) { |(key, value), result| result[key] = value.first }
  end

  def request_parameters
    URI.decode_www_form(subject.body).to_h
  end

end
