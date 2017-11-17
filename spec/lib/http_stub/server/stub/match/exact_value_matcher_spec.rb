describe HttpStub::Server::Stub::Match::ExactValueMatcher do

  describe "::match?" do

    let(:actual_value) { "some actual value" }

    subject { described_class.match?(stub_value, actual_value) }

    context "when the stub value is a string" do

      context "and the stub value is equal to the actual value" do

        let(:stub_value) { actual_value }

        it "returns true" do
          expect(subject).to be(true)
        end

      end

      context "and the stub value is not equal to the actual value" do

        let(:stub_value) { "some other value" }

        it "returns false" do
          expect(subject).to be(false)
        end

      end

    end

    context "when the stub value is an integer" do

      let(:stub_value) { 88 }

      context "whose string representation is equal to the actual value" do

        let(:actual_value) { "88" }

        it "returns true" do
          expect(subject).to be(true)
        end

      end

      context "whose string representation is not equal to the actual value" do

        let(:actual_value) { "89" }

        it "returns false" do
          expect(subject).to be(false)
        end

      end

    end

    context "when the stub value is another type" do

      let(:stub_value) { actual_value.to_sym }

      it "returns false" do
        expect(subject).to be(false)
      end

    end

  end

end
