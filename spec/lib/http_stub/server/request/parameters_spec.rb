describe HttpStub::Server::Request::Parameters do

  let(:parameter_hash) { {} }

  let(:parameters) { described_class.new(parameter_hash) }

  it "is a hash with indifferent access" do
    expect(parameters).to be_a(HashWithIndifferentAccess)
  end

  describe "::create" do

    let(:rack_params)  { { "some_parameter_name" => "some parameter value" } }
    let(:rack_request) { instance_double(Rack::Request, params: rack_params) }

    subject { described_class.create(rack_request) }

    it "returns http stub request parameters" do
      expect(subject).to be_an_instance_of(described_class)
    end

    it "returns parameters containing the rack request parameters" do
      expect(subject).to eql(rack_params)
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
