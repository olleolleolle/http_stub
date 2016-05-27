describe HttpStub::Server::Request::Headers do

  let(:header_hash) { {} }

  let(:headers) { described_class.new(header_hash) }

  it "is a hash with indifferent and insensitive access" do
    expect(headers).to be_a(HttpStub::Extensions::Core::Hash::IndifferentAndInsensitiveAccess)
  end

  describe "::create" do

    let(:non_header_env_elements) do
      {
        "rack.version"       => [1, 3],
        "rack.multithreaded" => true,
        "rack.multiprocess"  => false
      }
    end
    let(:env)          { non_header_env_elements.merge(header_env_elements) }
    let(:rack_request) { instance_double(Rack::Request, env: env) }

    subject { described_class.create(rack_request) }

    describe "when the request contains environment entries in upper case" do

      let(:header_env_elements) { (1..3).each_with_object({}) { |i, result| result["KEY_#{i}"] = "value#{i}" } }

      it "returns a hash containing those entries" do
        expect(subject).to eql("KEY_1" => "value1", "KEY_2" => "value2", "KEY_3" => "value3")
      end

    end

    describe "when the request contains environment entries in upper case prefixed with 'HTTP_'" do

      let(:header_env_elements) { (1..3).each_with_object({}) { |i, result| result["HTTP_KEY_#{i}"] = "value#{i}" } }

      it "returns a hash containing those entries with the prefix removed" do
        expect(subject).to include("KEY_1" => "value1", "KEY_2" => "value2", "KEY_3" => "value3")
      end

    end

    describe "when only has environment entries in lower case" do

      let(:header_env_elements) { {} }

      it "returns an empty hash" do
        expect(subject).to eql({})
      end

    end

  end

  describe "#to_s" do

    subject { headers.to_s }

    context "when headers are provided" do

      let(:header_hash) { (1..3).each_with_object({}) { |i, result| result["KEY_#{i}"] = "VALUE_#{i}" } }

      it "returns a string with each header name and value separated by ':'" do
        result = subject

        headers.each { |name, value| expect(result).to match(/#{name}:#{value}/) }
      end

      it "separates each header with comma for readability" do
        expect(subject).to match(/KEY_\d.VALUE_\d, KEY_\d.VALUE_\d, KEY_\d.VALUE_\d/)
      end

    end

    context "when headers are not provided" do

      let(:header_hash) { {} }

      it "returns an empty string" do
        expect(subject).to eql("")
      end

    end

  end

end
