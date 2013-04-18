describe HttpStub::Configurer::Request::RegexpableValue do

  let(:regexpable_value) { HttpStub::Configurer::Request::RegexpableValue.new(raw_value) }

  describe "#to_s" do

    describe "when the option's value is a regular expression" do

      let(:raw_value) { /.+?[a-z]/ }

      it "should return a string prefixed by 'regexp:'" do
        regexpable_value.to_s.should start_with("regexp:")
      end

      it "should contain the regular expression converted to a string" do
        regexpable_value.to_s.should end_with(".+?[a-z]")
      end

      describe "and the regular expression contain path separators" do

        let(:raw_value) { /\/some\/path/ }

        it "should represent the path separators as a single forward-slash" do
          regexpable_value.to_s.should end_with("/some/path")
        end

      end

    end

    describe "when the option's value is a string" do

      let(:raw_value) { "some string value" }

      it "should return the value unaltered" do
        regexpable_value.to_s.should eql(raw_value)
      end

    end

  end

  describe "#inspect" do

    let(:raw_value) { "some raw value" }

    it "should delegate to #to_s" do
      regexpable_value.should_receive(:to_s).and_return("some raw value as a string")

      regexpable_value.inspect.should eql("some raw value as a string")
    end

  end

end
