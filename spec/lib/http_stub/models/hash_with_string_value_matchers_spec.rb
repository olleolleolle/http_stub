describe HttpStub::Models::HashWithStringValueMatchers do

  let(:stubbed_hash) do
    (1..3).reduce({}) do |result, i|
      result["key#{i}"] = "value#{i}"
      result
    end
  end

  let(:value_matchers) do
    stubbed_hash.values.map { |value| double(HttpStub::Models::StringValueMatcher, to_s: value).as_null_object }
  end

  let(:value_matcher_hash) { HttpStub::Models::HashWithStringValueMatchers.new(stubbed_hash) }

  before(:example) do
    value_matchers.each { |value| allow(HttpStub::Models::StringValueMatcher).to receive(:new).with(value.to_s).and_return(value) }
  end

  it "is a hash" do
    expect(value_matcher_hash).to be_a(Hash)
  end

  describe "constructor" do

    it "creates a value matcher representation of each value in the hash" do
      value_matchers.each do |value|
        expect(HttpStub::Models::StringValueMatcher).to receive(:new).with(value.to_s).and_return(value)
      end

      expect(value_matcher_hash.values).to eql(value_matchers)
    end
    
  end
  
  describe "#match?" do
    
    context "when the stubbed hash contains multiple entries" do

      context "and the provided hash has the same number of entries" do

        context "and the keys match" do

          let(:provided_hash) do
            stubbed_hash.reduce({}) do |result, entry|
              result[entry[0]] = "another #{entry[1]}"
              result
            end
          end

          context "and the values match" do

            before(:example) do
              value_matchers.each { |value| allow(value).to receive(:match?).with("another #{value}").and_return(true) }
            end
            
            it "returns true" do
              expect(value_matcher_hash.match?(provided_hash)).to be_truthy
            end
            
          end

          context "and a value does not match" do

            before(:example) do
              value_matchers.each { |value| allow(value).to receive(:match?).with("another #{value}").and_return(true) }

              non_matching_value = value_matchers[1]
              allow(non_matching_value).to receive(:match?).with("another #{non_matching_value}").and_return(false)
            end

            it "returns false" do
              expect(value_matcher_hash.match?(provided_hash)).to be_falsey
            end

          end
          
        end

        context "and a key does not match" do

          let(:provided_hash) { { "key1" => "value1", "differentkey2" => "another value2", "key3" => "value3" } }

          it "determines if the corresponding value matches nil" do
            expected_values = [ "value1", nil, "value3" ]
            value_matchers.zip(expected_values).each do |value_matcher, expected_value|
              allow(value_matcher).to receive(:match?).with(expected_value)
            end

            value_matcher_hash.match?(provided_hash)
          end

          it "returns the result of evaluating the value matchers" do
            value_matchers.each { |value| allow(value).to receive(:match?).and_return(true) }

            expect(value_matcher_hash.match?(provided_hash)).to be_truthy
          end

        end

      end

      context "and the provided hash contains more entries" do

        let(:provided_hash) do
          (1..5).reduce({}) do |result, i|
            result["key#{i}"] = "another value#{i}"
            result
          end
        end

        context "and it has matching keys and values" do

          before(:example) do
            value_matchers.each { |value| allow(value).to receive(:match?).with("another #{value}").and_return(true) }
          end

          it "returns true" do
            expect(value_matcher_hash.match?(provided_hash)).to be_truthy
          end
          
        end
        
      end
      
    end

    context "when the stubbed hash is empty" do

      let(:stubbed_hash) { {} }

      context "and the provided hash is not empty" do

        let(:provided_hash) { { "key" => "value" } }

        it "returns true" do
          expect(value_matcher_hash.match?(provided_hash)).to be_truthy
        end

      end

      context "and the provided hash is empty" do

        let(:provided_hash) { {} }

        it "returns true" do
          expect(value_matcher_hash.match?(provided_hash)).to be_truthy
        end

      end
      
    end
    
  end
  
end
