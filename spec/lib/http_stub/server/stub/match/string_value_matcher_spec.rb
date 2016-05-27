describe HttpStub::Server::Stub::Match::StringValueMatcher do

  let(:stub_value) { "some stub value" }

  describe "::match?" do

    let(:actual_value) { "some actual value" }

    subject { described_class.match?(stub_value, actual_value) }

    shared_examples_for "a StringValueMatcher that matches an expected stub value" do

      it "determines if actual value should be omitted" do
        expect(HttpStub::Server::Stub::Match::OmittedValueMatcher).to(
          receive(:match?).with(expected_stub_match_value, actual_value)
        )

        subject
      end

      it "determines if the actual value matches a regular expression" do
        expect(HttpStub::Server::Stub::Match::RegexpValueMatcher).to(
          receive(:match?).with(expected_stub_match_value, actual_value)
        )

        subject
      end

      it "determines if the actual value exactly matches the stub value" do
        expect(HttpStub::Server::Stub::Match::ExactValueMatcher).to(
          receive(:match?).with(expected_stub_match_value, actual_value)
        )

        subject
      end

      it "determines if actual value should be omitted" do
        expect(HttpStub::Server::Stub::Match::OmittedValueMatcher).to(
          receive(:match?).with(expected_stub_match_value, actual_value)
        )

        subject
      end

      it "determines if the actual value matches a regular expression" do
        expect(HttpStub::Server::Stub::Match::RegexpValueMatcher).to(
          receive(:match?).with(expected_stub_match_value, actual_value)
        )

        subject
      end

      it "determines if the actual value exactly matches the stub value" do
        expect(HttpStub::Server::Stub::Match::ExactValueMatcher).to(
          receive(:match?).with(expected_stub_match_value, actual_value)
        )

        subject
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
