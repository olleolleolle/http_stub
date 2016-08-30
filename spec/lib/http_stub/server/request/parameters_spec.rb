describe HttpStub::Server::Request::Parameters do

  let(:parameter_hash) { { "some_parameter_name" => "some parameter value" } }

  let(:parameters) { described_class.new(parameter_hash) }

  it "is a hash with indifferent access" do
    expect(parameters).to be_a(HashWithIndifferentAccess)
  end

  describe "::create" do

    subject { described_class.create(parameter_hash) }

    it "returns http_stub request parameters" do
      expect(subject).to be_an_instance_of(described_class)
    end

    it "contains the provided parameters" do
      expect(subject).to eql(parameters)
    end

  end

  describe "#to_s" do

    subject { parameters.to_s }

    context "when parameters are provided" do

      let(:parameter_hash) { (1..3).each_with_object({}) { |i, result| result["key#{i}"] = "value#{i}" } }

      it "returns a string containing each parameter formatted as a conventional request parameter" do
        result = subject

        parameter_hash.each { |key, value| expect(result).to match(/#{key}=#{value}/) }
      end

      it "separates each parameter with the conventional request parameter delimiter" do
        expect(subject).to match(/key\d.value\d\&key\d.value\d\&key\d.value\d/)
      end

    end

    context "when parameters are not provided" do

      let(:parameter_hash) { {} }

      it "returns an empty string" do
        expect(subject).to eql("")
      end

    end

  end

end
