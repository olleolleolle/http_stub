describe HttpStub::Server::Stub::StringValueMatcher do

  let(:stub_value) { "some stub value" }

  let(:string_value_matcher) { HttpStub::Server::Stub::StringValueMatcher.new(stub_value) }

  describe "#match?" do

    let(:actual_value) { "some actual value" }

    shared_examples_for "a StringValueMatcher that matches an expected stub value" do

      it "determines if actual value should be omitted" do
        expect(HttpStub::Server::Stub::OmittedValueMatcher).to(
          receive(:match?).with(expected_stub_match_value, actual_value)
        )

        perform_match
      end

      it "determines if the actual value matches a regular expression" do
        expect(HttpStub::Server::Stub::RegexpValueMatcher).to(
          receive(:match?).with(expected_stub_match_value, actual_value)
        )

        perform_match
      end

      it "determines if the actual value exactly matches the stub value" do
        expect(HttpStub::Server::Stub::ExactValueMatcher).to(
          receive(:match?).with(expected_stub_match_value, actual_value)
        )

        perform_match
      end

      it "determines if actual value should be omitted" do
        expect(HttpStub::Server::Stub::OmittedValueMatcher).to(
          receive(:match?).with(expected_stub_match_value, actual_value)
        )

        perform_match
      end

      it "determines if the actual value matches a regular expression" do
        expect(HttpStub::Server::Stub::RegexpValueMatcher).to(
          receive(:match?).with(expected_stub_match_value, actual_value)
        )

        perform_match
      end

      it "determines if the actual value exactly matches the stub value" do
        expect(HttpStub::Server::Stub::ExactValueMatcher).to(
          receive(:match?).with(expected_stub_match_value, actual_value)
        )

        perform_match
      end

    end

    context "when the provided stub value is a string" do

      let(:stub_value)                { "some stub value" }
      let(:expected_stub_match_value) { "some stub value" }

      it_behaves_like "a StringValueMatcher that matches an expected stub value"

    end

    context "when the provided stub value is not a string" do

      let(:stub_value)                { 88 }
      let(:expected_stub_match_value) { "88" }

      it_behaves_like "a StringValueMatcher that matches an expected stub value"

    end

    context "when an omitted match occurs" do

      before(:example) { expect(HttpStub::Server::Stub::OmittedValueMatcher).to receive(:match?).and_return(true) }

      it "returns true" do
        expect(perform_match).to be_truthy
      end

    end

    context "when a regular expression match occurs" do

      before(:example) { expect(HttpStub::Server::Stub::RegexpValueMatcher).to receive(:match?).and_return(true) }

      it "returns true" do
        expect(perform_match).to be_truthy
      end

    end

    context "when an exact match occurs" do

      before(:example) { expect(HttpStub::Server::Stub::ExactValueMatcher).to receive(:match?).and_return(true) }

      it "returns true" do
        expect(perform_match).to be_truthy
      end

    end

    context "when no match occurs" do

      it "returns false" do
        expect(perform_match).to be_falsey
      end

    end
    
    def perform_match
      string_value_matcher.match?(actual_value)
    end

  end

  describe "#to_s" do

    it "returns the stub value provided" do
      expect(string_value_matcher.to_s).to eql(stub_value)
    end

  end

end
