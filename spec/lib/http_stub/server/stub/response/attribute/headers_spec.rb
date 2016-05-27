describe HttpStub::Server::Stub::Response::Attribute::Headers do

  let(:stub_headers) { (1..3).each_with_object({}) { |i, result| result["key#{i}"] = "value #{i}" } }

  let(:headers) { described_class.new(stub_headers) }

  describe "#with_values_from" do

    let(:request) { HttpStub::Server::Request::Request }

    let(:interpolated_headers) do
      stub_headers.keys.each_with_object({}).with_index do |(name, result), i|
        result[name] = "interpolated value #{i + 1}"
      end
    end

    subject { headers.with_values_from(request) }

    it "interpolates each header value with values from the request" do
      stub_headers.values.each do |header_value|
        expect(HttpStub::Server::Stub::Response::Attribute::Interpolator).to(
          receive(:interpolate).with(header_value, request)
        )
      end

      subject
    end

    it "returns a hash containing the interpolated values" do
      stub_headers.values.zip(interpolated_headers.values).each do |header_value, interpolated_value|
        allow(HttpStub::Server::Stub::Response::Attribute::Interpolator).to(
          receive(:interpolate).with(header_value, anything).and_return(interpolated_value)
        )
      end

      expect(subject).to eql(interpolated_headers)
    end

  end

  describe "#to_s" do

    subject { headers.to_s }

    it "returns a string with each header name and value separated by ':'" do
      result = subject

      stub_headers.each { |name, value| expect(result).to match(/#{name}:#{value}/) }
    end

    it "separates each header with comma for readability" do
      expect(subject).to match(/key\d.value \d, key\d.value \d, key\d.value \d/)
    end

  end

end
