describe HttpStub::Extensions::Core::Hash do

  describe "#downcase_and_underscore_keys" do

    describe "when the hash contains keys which are strings" do

      let(:hash) do
        { "lower" => 1, "UPPER" => 2, "MiXeDcAsE" => 3 }
      end

      it "downcases the string keys" do
        expect(hash.downcase_and_underscore_keys).to eql({ "lower" => 1, "upper" => 2, "mixedcase" => 3 })
      end

      describe "and keys contain underscores and hyphens" do

        let(:hash) do
          { "has_underscore" => 1, "has-hypen" => 2, "has_underscore_and-hypen" => 3 }
        end

        it "downcases the string keys" do
          expect(hash.downcase_and_underscore_keys).to eql({ "has_underscore" => 1,
                                                         "has_hypen" => 2,
                                                         "has_underscore_and_hypen" => 3 })
        end

      end

    end

    describe "when the hash contains keys which are not strings" do

      let(:hash) do
        { 1 => 2, :symbol => 3, nil => 4 }
      end

      it "does not alter a hash" do
        expect(hash.downcase_and_underscore_keys).to eql({ 1 => 2, :symbol => 3, nil => 4 })
      end

    end

  end

  describe "#has_hash?" do

    describe "when many elements are provided" do

      let(:hash_parameter) { { "key1" => "value1", "key2" => "value2", "key3" => "value3" } }

      describe "and the hash contains only those elements" do

        let(:hash) { hash_parameter }

        it "returns true" do
          expect(hash.has_hash?(hash_parameter)).to be(true)
        end

      end

      describe "and the hash contains more than those elements" do

        let(:hash) { hash_parameter.merge("key4" => "value4") }

        it "returns true" do
          expect(hash.has_hash?(hash_parameter)).to be(true)
        end

      end

      describe "and the hash contains keys that match but values that do not match" do

        let(:hash) { { "key1" => "value1", "key2" => "nonMatchingValue", "key3" => "value3" } }

        it "returns false" do
          expect(hash.has_hash?(hash_parameter)).to be(false)
        end

      end

      describe "and the hash contains less than those elements" do

        let(:hash) { { "key1" => "value1", "key3" => "value3" } }

        it "returns false" do
          expect(hash.has_hash?(hash_parameter)).to be(false)
        end

      end

      describe "and the hash contains no elements" do

        let(:hash) { {} }

        it "returns false" do
          expect(hash.has_hash?(hash_parameter)).to be(false)
        end

      end

    end

    describe "when no elements are provided" do

      let(:hash_parameter) { {} }

      describe "and the hash contains no element" do

        let(:hash) { {} }

        it "returns true" do
          expect(hash.has_hash?(hash_parameter)).to be(true)
        end

      end

      describe "when the hash contains elements" do

        let(:hash) { { "key" => "value" } }

        it "returns true" do
          expect(hash.has_hash?(hash_parameter)).to be(true)
        end

      end

    end

    describe "when a nil hash is provided" do

      let(:hash_parameter) { nil }

      describe "and the hash contains no elements" do

        let(:hash) { {} }

        it "returns true" do
          expect(hash.has_hash?(hash_parameter)).to be(true)
        end

      end

      describe "when the hash contains elements" do

        let(:hash) { { "key" => "value" } }

        it "returns true" do
          expect(hash.has_hash?(hash_parameter)).to be(true)
        end

      end

    end

  end

end
