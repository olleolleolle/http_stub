describe HttpStub::Server::Stub::Match::OmittedValueMatcher do

  describe "::match?" do

    let(:actual_value) { nil }

    subject { described_class.match?(stub_value, actual_value) }

    context "when the stub value is the symbol :omitted" do

      let(:stub_value) { :omitted }

      context "and the actual value is nil" do

        let(:actual_value) { nil }

        it "returns true" do
          expect(subject).to be(true)
        end

      end

      context "and the actual value is a non-empty string" do

        let(:actual_value) { "some non-empty string" }

        it "returns false" do
          expect(subject).to be(false)
        end

      end

      context "and the actual value is an empty string" do

        let(:actual_value) { "" }

        it "returns false" do
          expect(subject).to be(false)
        end

      end

    end

    context "when the stub value is another symbol" do

      let(:stub_value) { :some_other_symbol }

      it "returns false" do
        expect(subject).to be(false)
      end

    end

    context "when the stub value is a string" do

      let(:stub_value)   { "some string" }

      it "returns false" do
        expect(subject).to be(false)
      end

    end

    context "when the stub value is a regular expression" do

      let(:stub_value) { /some regular expression/ }

      it "returns false" do
        expect(subject).to be(false)
      end

    end

  end

end
