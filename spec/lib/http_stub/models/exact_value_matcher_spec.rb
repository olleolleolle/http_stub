describe HttpStub::Models::ExactValueMatcher do

  describe ".match?" do

    let(:stub_value) { "some stub value" }

    describe "when the stub value is equal to the actual value" do

      let(:actual_value) { stub_value }

      it "returns true" do
        expect(perform_match).to be_truthy
      end

    end

    describe "when the stub value is not equal to the actual value" do

      let(:actual_value) { "not equal to stub value" }

      it "returns false" do
        expect(perform_match).to be_falsey
      end

    end

    def perform_match
      HttpStub::Models::ExactValueMatcher.match?(stub_value, actual_value)
    end

  end

end
