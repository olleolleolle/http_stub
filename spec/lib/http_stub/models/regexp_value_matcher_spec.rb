describe HttpStub::Models::RegexpValueMatcher do

  describe ".match?" do

    context "when the stub value is a string prefixed with 'regexp:'" do

      let(:stub_value) { "regexp:^a[0-9]*\\$z$" }

      context "and the actual value matches the regular expression" do

        let(:actual_value) { "a789$z" }

        it "should return true" do
          perform_match.should be_true
        end

      end

      context "and the actual value does not match the regular expression" do

        let(:actual_value) { "a789" }

        it "should return false" do
          perform_match.should be_false
        end

      end

    end

    context "when the provided value is not a string prefixed with 'regexp'" do

      let(:stub_value) { "does not start with regexp:" }
      let(:actual_value) { "some actual value" }

      it "should return false" do
        perform_match.should be_false
      end

    end
    
    def perform_match
      HttpStub::Models::RegexpValueMatcher.match?(stub_value, actual_value)
    end

  end

end
