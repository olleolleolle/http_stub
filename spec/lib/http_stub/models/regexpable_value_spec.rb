describe HttpStub::Models::RegexpableValue do

  let(:value) { "a simple string" }

  let(:regexpable_value) { HttpStub::Models::RegexpableValue.new(value) }

  describe "#match?" do

    describe "when the value is a string prefixed with 'regexp:'" do

      let(:value) { "regexp:^a[0-9]*z$" }

      describe "and the provided value matches the regular expression" do

        let(:other_value) { "a789z" }

        it "should return true" do
          regexpable_value.match?(other_value).should be_true
        end

      end

      describe "and the provided value does not match the regular expression" do

        let(:other_value) { "a789" }

        it "should return false" do
          regexpable_value.match?(other_value).should be_false
        end

      end

    end

    describe "when the value is a simple string" do

      describe "and the provided value is equal to the string" do

        let(:other_value) { value }

        it "should return true" do
          regexpable_value.match?(other_value).should be_true
        end

      end

      describe "and the provided value is not equal to the string" do

        let(:other_value) { "a not equal string" }

        it "should return false" do
          regexpable_value.match?(other_value).should be_false
        end

      end

    end

  end

  describe "#to_s" do

    it "should return the value provided" do
      regexpable_value.to_s.should eql(value)
    end

  end

end
