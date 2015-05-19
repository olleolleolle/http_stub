describe HttpStub::Server::OmittedValueMatcher  do

  describe ".match?" do

    context "when the stubbed value is 'control:omitted'" do

      let(:stub_value) { "control:omitted" }

      context "and the actual value is nil" do

        let(:actual_value) { nil }

        it "returns true" do
          expect(perform_match).to be_truthy
        end

      end

      context "and the actual value is non-empty string" do

        let(:actual_value) { "some non-empty string" }

        it "returns false" do
          expect(perform_match).to be_falsey
        end

      end

      context "and the actual value is an empty string" do

        let(:actual_value) { "" }

        it "returns false" do
          expect(perform_match).to be_falsey
        end

      end

    end

    context "when the stub value is not 'control:omitted'" do

      let(:stub_value) { "some other stub value" }
      let(:actual_value) { nil }

      it "returns false" do
        expect(perform_match).to be_falsey
      end

    end

    def perform_match
      HttpStub::Server::OmittedValueMatcher.match?(stub_value, actual_value)
    end

  end

end
