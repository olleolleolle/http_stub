describe HttpStub::Server::Stub::Match::HashWithStringValueMatchers do

  let(:stubbed_hash) do
    (1..3).reduce({}) do |result, i|
      result["key#{i}"] = "value#{i}"
      result
    end
  end

  let(:value_matchers) do
    stubbed_hash.values.map do |value|
      double(HttpStub::Server::Stub::Match::StringValueMatcher, to_s: value).as_null_object
    end
  end

  let(:value_matcher_hash) { HttpStub::Server::Stub::Match::HashWithStringValueMatchers.new(stubbed_hash) }

  before(:example) do
    value_matchers.each do |value|
      allow(HttpStub::Server::Stub::Match::StringValueMatcher).to receive(:new).with(value.to_s).and_return(value)
    end
  end

  it "is a hash" do
    expect(value_matcher_hash).to be_a(Hash)
  end

  describe "constructor" do

    it "creates a value matcher representation of each value in the hash" do
      value_matchers.each do |value|
        expect(HttpStub::Server::Stub::Match::StringValueMatcher).to receive(:new).with(value.to_s).and_return(value)
      end

      expect(value_matcher_hash.values).to eql(value_matchers)
    end
    
  end
  
  describe "#matches?" do

    subject { value_matcher_hash.matches?(provided_hash) }
    
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
              value_matchers.each do |value|
                allow(value).to receive(:matches?).with("another #{value}").and_return(true)
              end
            end
            
            it "returns true" do
              expect(subject).to be(true)
            end
            
          end

          context "and a value does not match" do

            before(:example) do
              value_matchers.each do |value|
                allow(value).to receive(:matches?).with("another #{value}").and_return(true)
              end

              non_matching_value = value_matchers[1]
              allow(non_matching_value).to receive(:matches?).with("another #{non_matching_value}").and_return(false)
            end

            it "returns false" do
              expect(subject).to be(false)
            end

          end
          
        end

        context "and a key does not match" do

          let(:provided_hash) { { "key1" => "value1", "differentkey2" => "another value2", "key3" => "value3" } }

          it "determines if the corresponding value matches nil" do
            expected_values = [ "value1", nil, "value3" ]
            value_matchers.zip(expected_values).each do |value_matcher, expected_value|
              allow(value_matcher).to receive(:matches?).with(expected_value)
            end

            subject
          end

          it "returns the result of evaluating the value matchers" do
            value_matchers.each { |value| allow(value).to receive(:matches?).and_return(true) }

            expect(subject).to be(true)
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
            value_matchers.each { |value| allow(value).to receive(:matches?).with("another #{value}").and_return(true) }
          end

          it "returns true" do
            expect(subject).to be(true)
          end
          
        end
        
      end
      
    end

    context "when the stubbed hash is empty" do

      let(:stubbed_hash) { {} }

      context "and the provided hash is not empty" do

        let(:provided_hash) { { "key" => "value" } }

        it "returns true" do
          expect(subject).to be(true)
        end

      end

      context "and the provided hash is empty" do

        let(:provided_hash) { {} }

        it "returns true" do
          expect(subject).to be(true)
        end

      end
      
    end
    
  end
  
end
