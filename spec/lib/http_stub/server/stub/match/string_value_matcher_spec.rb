describe HttpStub::Server::Stub::Match::StringValueMatcher do

  describe "::match?" do

    let(:stub_value)   { :some_stub_value }
    let(:actual_value) { "some actual value" }

    subject { described_class.match?(stub_value, actual_value) }

    it "determines if actual value matches by omission" do
      expect(HttpStub::Server::Stub::Match::OmittedValueMatcher).to receive(:match?).with(stub_value, actual_value)

      subject
    end

    it "determines if the actual value matches the stub value using a regular expression" do
      expect(HttpStub::Server::Stub::Match::RegexpValueMatcher).to receive(:match?).with(stub_value, actual_value)

      subject
    end

    it "determines if the actual value exactly matches the stub value" do
      expect(HttpStub::Server::Stub::Match::ExactValueMatcher).to receive(:match?).with(stub_value, actual_value)

      subject
    end

    context "when an omitted match occurs" do

      before(:example) do
        expect(HttpStub::Server::Stub::Match::OmittedValueMatcher).to receive(:match?).and_return(true)
      end

      it "returns true" do
        expect(subject).to be(true)
      end

    end

    context "when a regular expression match occurs" do

      before(:example) do
        expect(HttpStub::Server::Stub::Match::RegexpValueMatcher).to receive(:match?).and_return(true)
      end

      it "returns true" do
        expect(subject).to be(true)
      end

    end

    context "when an exact match occurs" do

      before(:example) do
        expect(HttpStub::Server::Stub::Match::ExactValueMatcher).to receive(:match?).and_return(true)
      end

      it "returns true" do
        expect(subject).to be(true)
      end

    end

    context "when no match occurs" do

      it "returns false" do
        expect(subject).to be(false)
      end

    end

  end

end
