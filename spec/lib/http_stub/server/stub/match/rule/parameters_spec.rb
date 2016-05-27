describe HttpStub::Server::Stub::Match::Rule::Parameters do

  let(:stub_parameters) { (1..3).each_with_object({}) { |i, result| result["key#{i}"] = "value#{i}" } }

  let(:parameters) { described_class.new(stub_parameters) }

  it "is a hash with indifferent access" do
    expect(parameters).to be_a(::HashWithIndifferentAccess)
  end

  context "when no parameters are provided" do

    let(:stub_parameters) { nil }

    it "is empty" do
      expect(parameters.empty?).to be(true)
    end

  end

  describe "#matches?" do

    let(:request_parameters) { instance_double(HttpStub::Server::Request::Parameters) }
    let(:request)            { instance_double(HttpStub::Server::Request::Request, parameters: request_parameters) }
    let(:logger)             { instance_double(Logger) }

    subject { parameters.matches?(request, logger) }

    it "determines if the stub parameter and request parameter hashes match" do
      expect(HttpStub::Server::Stub::Match::HashMatcher).to receive(:match?).with(parameters, request_parameters)

      subject
    end

    it "returns the result of the match" do
      allow(HttpStub::Server::Stub::Match::HashMatcher).to receive(:match?).and_return(true)

      expect(subject).to eql(true)
    end

  end

  describe "#to_s" do

    subject { parameters.to_s }

    describe "when multiple parameters are provided" do

      let(:stub_parameters) { (1..3).each_with_object({}) { |i, result| result["key#{i}"] = "value#{i}" } }

      it "returns a string containing each parameter formatted as a conventional request parameter" do
        result = subject

        stub_parameters.each { |key, value| expect(result).to match(/#{key}=#{value}/) }
      end

      it "separates each parameter with the conventional request parameter delimiter" do
        expect(subject).to match(/key\d.value\d\&key\d.value\d\&key\d.value\d/)
      end

    end

    describe "when empty parameters are provided" do

      let(:stub_parameters) { {} }

      it "returns an empty string" do
        expect(subject).to eql("")
      end

    end

    describe "when nil parameters are provided" do

      let(:stub_parameters) { nil }

      it "returns an empty string" do
        expect(subject).to eql("")
      end

    end

  end

end
