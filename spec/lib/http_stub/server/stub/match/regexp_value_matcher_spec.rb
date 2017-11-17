describe HttpStub::Server::Stub::Match::RegexpValueMatcher do

  describe "::match?" do

    subject { described_class.match?(stub_value, actual_value) }

    context "when the stub value is a regular expression" do

      let(:stub_value) { /^a[0-9]*\$z$/ }

      context "and the actual value matches the regular expression" do

        let(:actual_value) { "a789$z" }

        it "returns true" do
          expect(subject).to be(true)
        end

      end

      context "and the actual value does not match the regular expression" do

        let(:actual_value) { "a789" }

        it "returns false" do
          expect(subject).to be(false)
        end

      end

    end

    context "when the stub value is a string" do

      let(:stub_value)   { "some string" }
      let(:actual_value) { stub_value }

      it "returns false" do
        expect(subject).to be(false)
      end

    end

    context "when the stub value is a symbol" do

      let(:stub_value)   { :some_symbol }
      let(:actual_value) { stub_value }

      it "returns false" do
        expect(subject).to be(false)
      end

    end

  end

end
