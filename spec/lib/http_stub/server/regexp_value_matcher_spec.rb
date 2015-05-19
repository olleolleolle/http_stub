describe HttpStub::Server::RegexpValueMatcher do

  describe ".match?" do

    context "when the stub value is a string prefixed with 'regexp:'" do

      let(:stub_value) { "regexp:^a[0-9]*\\$z$" }

      context "and the actual value matches the regular expression" do

        let(:actual_value) { "a789$z" }

        it "returns true" do
          expect(perform_match).to be_truthy
        end

      end

      context "and the actual value does not match the regular expression" do

        let(:actual_value) { "a789" }

        it "returns false" do
          expect(perform_match).to be_falsey
        end

      end

    end

    context "when the provided value is not a string prefixed with 'regexp'" do

      let(:stub_value) { "does not start with regexp:" }
      let(:actual_value) { "some actual value" }

      it "returns false" do
        expect(perform_match).to be_falsey
      end

    end
    
    def perform_match
      HttpStub::Server::RegexpValueMatcher.match?(stub_value, actual_value)
    end

  end

end
