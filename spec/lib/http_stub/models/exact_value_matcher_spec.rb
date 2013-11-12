describe HttpStub::Models::ExactValueMatcher do

  describe ".match?" do

    let(:stub_value) { "some stub value" }

    describe "when the stub value is equal to the actual value" do

      let(:actual_value) { stub_value }

      it "should return true" do
        perform_match.should be_true
      end

    end

    describe "when the stub value is not equal to the actual value" do

      let(:actual_value) { "not equal to stub value" }

      it "should return false" do
        perform_match.should be_false
      end

    end

    def perform_match
      HttpStub::Models::ExactValueMatcher.match?(stub_value, actual_value)
    end

  end

end
