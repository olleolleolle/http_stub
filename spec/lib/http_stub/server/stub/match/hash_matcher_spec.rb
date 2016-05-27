describe HttpStub::Server::Stub::Match::HashMatcher do

  let(:stub_hash) do
    (1..3).each_with_object({}) { |i, result| result["key#{i}"] = "stub value #{i}" }
  end

  let(:string_value_matcher) { HttpStub::Server::Stub::Match::StringValueMatcher }

  describe "::match?" do

    let(:actual_hash) { {} }

    subject { described_class.match?(stub_hash, actual_hash) }
    
    context "when the stub hash contains multiple entries" do

      it "returns the result of evaluating a match for each stub value" do
        stub_hash.values.each do |stub_value|
          allow(string_value_matcher).to receive(:match?).with(stub_value, anything).and_return(true)
        end

        expect(subject).to be(true)
      end

      context "and the actual hash has the same number of entries" do

        context "and the keys match" do

          let(:actual_hash) do
            (1..3).each_with_object({}) { |i, result| result["key#{i}"] = "actual value #{i}" }
          end

          context "and the values match" do

            before(:example) { allow(string_value_matcher).to receive(:match?).and_return(true) }

            it "returns true" do
              expect(subject).to be(true)
            end
            
          end

          context "and a value does not match" do

            before(:example) do
              allow(string_value_matcher).to receive(:match?).and_return(true)
              allow(string_value_matcher).to receive(:match?).with("stub value 2", "actual value 2").and_return(false)
            end

            it "returns false" do
              expect(subject).to be(false)
            end

          end
          
        end

        context "and a key does not match" do

          let(:actual_hash) do
            { "key1" => "actual value 1", "differentkey2" => "different value 2", "key3" => "actual value 3" }
          end

          before(:example) { allow(string_value_matcher).to receive(:match?).and_return(true) }

          it "determines if the corresponding value matches nil" do
            expect(string_value_matcher).to receive(:match?).with("stub value 2", nil)

            subject
          end

        end

      end

      context "and the actual hash contains more entries" do

        let(:actual_hash) do
          (1..5).each_with_object({}) { |i, result| result["key#{i}"] = "actual value #{i}" }
        end

        it "only evaluates a match for each stub value" do
          stub_hash.values.each do |stub_value|
            allow(string_value_matcher).to receive(:match?).with(stub_value, anything).and_return(true)
          end

          expect(subject).to be(true)
        end
        
      end
      
    end

    context "when the stubbed hash is empty" do

      let(:stub_hash) { {} }

      context "and the actual hash is not empty" do

        let(:actual_hash) { { "key" => "value" } }

        it "returns true" do
          expect(subject).to be(true)
        end

      end

      context "and the provided hash is empty" do

        let(:actual_hash) { {} }

        it "returns true" do
          expect(subject).to be(true)
        end

      end
      
    end
    
  end
  
end
