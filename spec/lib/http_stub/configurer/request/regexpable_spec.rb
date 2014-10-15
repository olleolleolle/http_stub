describe HttpStub::Configurer::Request::Regexpable do

  describe "#format" do

    describe "when the value is a string" do

      let(:value) { "some string value" }

      it "returns the value unaltered" do
        expect(HttpStub::Configurer::Request::Regexpable.format(value)).to eql(value)
      end

    end

    describe "when the value is a regular expression" do

      let(:value) { /.+?[a-z]/ }

      it "returns a string prefixed by 'regexp:'" do
        expect(HttpStub::Configurer::Request::Regexpable.format(value)).to start_with("regexp:")
      end

      it "contains the regular expression converted to a string" do
        expect(HttpStub::Configurer::Request::Regexpable.format(value)).to end_with(".+?[a-z]")
      end

      describe "and the regular expression contain escaped meta characters" do

        let(:value) { /\^\+\[/ }

        it "returns a string that retains the escape characters" do
          expect(HttpStub::Configurer::Request::Regexpable.format(value)).to include("\\^\\+\\[")
        end

      end

      describe "and the regular expression contain path separators" do

        let(:value) { /\/some\/path/ }

        it "represents the path separators as a single forward-slash" do
          expect(HttpStub::Configurer::Request::Regexpable.format(value)).to end_with("/some/path")
        end

      end

    end

    describe "when the value is a hash" do

      describe "and the hash has multiple entries" do

        let(:value) { { key1: "value1", key2: /^.*value2$/, key3: "value3" } }

        it "returns a json representation of the hash whose values are their regexpable form" do
          expected_formatted_hash = {key1: "value1", key2: "regexp:^.*value2$", key3: "value3"}

          expect(HttpStub::Configurer::Request::Regexpable.format(value)).to eql(expected_formatted_hash)
        end

      end

      describe "and the hash is empty" do

        let(:value) { {} }

        it "returns an empty hash" do
          expect(HttpStub::Configurer::Request::Regexpable.format(value)).to eql({})
        end

      end

    end

  end

end
