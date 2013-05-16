describe HttpStub::Configurer::Request::Regexpable do

  describe "#format" do

    describe "when the value is a string" do

      let(:value) { "some string value" }

      it "should return the value unaltered" do
        HttpStub::Configurer::Request::Regexpable.format(value).should eql(value)
      end

    end

    describe "when the value is a regular expression" do

      let(:value) { /.+?[a-z]/ }

      it "should return a string prefixed by 'regexp:'" do
        HttpStub::Configurer::Request::Regexpable.format(value).should start_with("regexp:")
      end

      it "should contain the regular expression converted to a string" do
        HttpStub::Configurer::Request::Regexpable.format(value).should end_with(".+?[a-z]")
      end

      describe "and the regular expression contain escaped meta characters" do

        let(:value) { /\^\+\[/ }

        it "should return a string that retains the escape characters" do
          HttpStub::Configurer::Request::Regexpable.format(value).should include("\\^\\+\\[")
        end

      end

      describe "and the regular expression contain path separators" do

        let(:value) { /\/some\/path/ }

        it "should represent the path separators as a single forward-slash" do
          HttpStub::Configurer::Request::Regexpable.format(value).should end_with("/some/path")
        end

      end

    end

    describe "when the value is a hash" do

      describe "and the hash has multiple entries" do

        let(:value) { { key1: "value1", key2: /^.*value2$/, key3: "value3" } }

        it "should return a json representation of the hash whose values are their regexpable form" do
          expected_formatted_hash = {key1: "value1", key2: "regexp:^.*value2$", key3: "value3"}

          HttpStub::Configurer::Request::Regexpable.format(value).should eql(expected_formatted_hash)
        end

      end

      describe "and the hash is empty" do

        let(:value) { {} }

        it "should return an empty hash" do
          HttpStub::Configurer::Request::Regexpable.format(value).should eql({})
        end

      end

    end

  end

end
