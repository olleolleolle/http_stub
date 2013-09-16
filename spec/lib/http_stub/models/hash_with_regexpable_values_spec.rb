describe HttpStub::Models::HashWithRegexpableValues do

  let(:stubbed_hash) do
    (1..3).reduce({}) do |result, i|
      result["key#{i}"] = "value#{i}"
      result
    end
  end

  let(:regexpable_values) do
    stubbed_hash.values.map { |value| double(HttpStub::Models::RegexpableValue, to_s: value).as_null_object }
  end

  let(:regexpable_hash) { HttpStub::Models::HashWithRegexpableValues.new(stubbed_hash) }

  before(:each) do
    regexpable_values.each { |value| HttpStub::Models::RegexpableValue.stub(:new).with(value.to_s).and_return(value) }
  end

  it "should be hash" do
    regexpable_hash.should be_a(Hash)
  end

  describe "constructor" do

    it "should create a regexpable representation of each value in the hash" do
      regexpable_values.each do |value|
        HttpStub::Models::RegexpableValue.should_receive(:new).with(value.to_s).and_return(value)
      end

      regexpable_hash.values.should eql(regexpable_values)
    end
    
  end
  
  describe "#match?" do
    
    describe "when the stubbed hash contains multiple entries" do
      
      describe "and the provided hash has the same number of entries" do
        
        describe "and the keys match" do

          let(:provided_hash) do
            stubbed_hash.reduce({}) do |result, entry|
              result[entry[0]] = "another #{entry[1]}"
              result
            end
          end

          describe "and the values match" do

            before(:each) do
              regexpable_values.each { |value| value.stub(:match?).with("another #{value}").and_return(true) }
            end
            
            it "should return true" do
              regexpable_hash.match?(provided_hash).should be_true
            end
            
          end
          
          describe "and a value does not match" do

            before(:each) do
              regexpable_values.each { |value| value.stub(:match?).with("another #{value}").and_return(true) }

              non_matching_value = regexpable_values[1]
              non_matching_value.stub(:match?).with("another #{non_matching_value}").and_return(false)
            end

            it "should return false" do
              regexpable_hash.match?(provided_hash).should be_false
            end

          end
          
        end
        
        describe "and a key does not match" do

          let(:provided_hash) { { "key1" => "value1", "differentkey2" => "another value2", "key3" => "value3" } }

          before(:each) do
            regexpable_values.each { |value| value.stub(:match?).with(value.to_s).and_return(true) }
          end

          it "should return false" do
            regexpable_hash.match?(provided_hash).should be_false
          end

        end
        
      end
      
      describe "and the provided hash contains more entries" do

        let(:provided_hash) do
          (1..5).reduce({}) do |result, i|
            result["key#{i}"] = "another value#{i}"
            result
          end
        end

        describe "and it has matching keys and values" do

          before(:each) do
            regexpable_values.each { |value| value.stub(:match?).with("another #{value}").and_return(true) }
          end

          it "should return true" do
            regexpable_hash.match?(provided_hash).should be_true
          end
          
        end
        
      end
      
    end
    
    describe "when the stubbed hash is empty" do

      let(:stubbed_hash) { {} }

      describe "and the provided hash is not empty" do

        let(:provided_hash) { { "key" => "value" } }

        it "should return true" do
          regexpable_hash.match?(provided_hash).should be_true
        end

      end
      
      describe "and the provided hash is empty" do

        let(:provided_hash) { {} }

        it "should return true" do
          regexpable_hash.match?(provided_hash).should be_true
        end

      end
      
    end
    
  end
  
end
