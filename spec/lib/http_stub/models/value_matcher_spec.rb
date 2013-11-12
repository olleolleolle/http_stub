describe HttpStub::Models::ValueMatcher do

  let(:stub_value) { "some stub value" }

  let(:value_matcher) { HttpStub::Models::ValueMatcher.new(stub_value) }

  describe "#match?" do

    let(:actual_value) { "some actual value" }

    it "should determine if actual value should be omitted" do
      HttpStub::Models::OmittedValueMatcher.should_receive(:match?).with(stub_value, actual_value)

      perform_match
    end

    it "should determine if the actual value matches a regular expression" do
      HttpStub::Models::RegexpValueMatcher.should_receive(:match?).with(stub_value, actual_value)

      perform_match
    end

    it "should determine if the actual value exactly matches the stub value" do
      HttpStub::Models::ExactValueMatcher.should_receive(:match?).with(stub_value, actual_value)

      perform_match
    end

    context "when an omitted match occurs" do

      before(:each) { HttpStub::Models::OmittedValueMatcher.should_receive(:match?).and_return(true) }

      it "should return true" do
        perform_match.should be_true
      end

    end

    context "when a regular expression match occurs" do

      before(:each) { HttpStub::Models::RegexpValueMatcher.should_receive(:match?).and_return(true) }

      it "should return true" do
        perform_match.should be_true
      end

    end

    context "when an exact match occurs" do

      before(:each) { HttpStub::Models::ExactValueMatcher.should_receive(:match?).and_return(true) }

      it "should return true" do
        perform_match.should be_true
      end

    end

    context "when no match occurs" do

      it "should return false" do
        perform_match.should be_false
      end

    end
    
    def perform_match
      value_matcher.match?(actual_value)
    end

  end

  describe "#to_s" do

    it "should return the stub value provided" do
      value_matcher.to_s.should eql(stub_value)
    end

  end

end
