describe HttpStub::Models::OmittedValueMatcher  do

  describe ".match?" do

    context "when the stubbed value is 'control:omitted'" do

      let(:stub_value) { "control:omitted" }

      context "and the actual value is nil" do

        let(:actual_value) { nil }

        it "should return true" do
          perform_match.should be_true
        end

      end

      context "and the actual value is non-empty string" do

        let(:actual_value) { "some non-empty string" }

        it "should return false" do
          perform_match.should be_false
        end

      end

      context "and the actual value is an empty string" do

        let(:actual_value) { "" }

        it "should return false" do
          perform_match.should be_false
        end

      end

    end

    context "when the stub value is not 'control:omitted'" do

      let(:stub_value) { "some other stub value" }
      let(:actual_value) { nil }

      it "should return false" do
        perform_match.should be_false
      end

    end

    def perform_match
      HttpStub::Models::OmittedValueMatcher.match?(stub_value, actual_value)
    end

  end

end
