describe HttpStub::Configurer::Request::HashWithRegexpableValues do

  let(:hash_with_regexpable_values) { HttpStub::Configurer::Request::HashWithRegexpableValues.new(raw_hash) }

  describe "#to_json" do

    describe "when provided a hash with multiple entries" do

      let(:raw_hash) { { key1: "value1", key2: "value2", key3: "value3" } }

      it "should return a json representation of the hash whose values are their regexpable form" do
        raw_hash.values.each do |value|
          regexpable_value = double(HttpStub::Configurer::Request::RegexpableValue, to_s: "regexpable_#{value}")
          HttpStub::Configurer::Request::RegexpableValue.stub!(:new).with(value).and_return(regexpable_value)
        end

        expected_json = { key1: "regexpable_value1", key2: "regexpable_value2", key3: "regexpable_value3" }.to_json
        hash_with_regexpable_values.to_json.should eql(expected_json)
      end

    end

    describe "when provided an empty hash" do

      let(:raw_hash) { {} }

      it "should return a json representation of an empty hash" do
        hash_with_regexpable_values.to_json.should eql({}.to_json)
      end

    end

  end

end
