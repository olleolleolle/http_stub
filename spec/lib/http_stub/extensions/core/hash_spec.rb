describe HttpStub::Extensions::Core::Hash do

  describe "#underscore_keys" do

    subject { hash.underscore_keys }

    context "when the hash contains keys which are strings" do

      context "and keys contain underscores and hyphens" do

        let(:hash) do
          { "has_underscore" => 1, "has-hypen" => 2, "has_underscore_and-hypen" => 3 }
        end

        it "downcases the string keys" do
          expect(subject).to eql({ "has_underscore" => 1, "has_hypen" => 2, "has_underscore_and_hypen" => 3 })
        end

      end

    end

    context "when the hash contains keys which are not strings" do

      let(:hash) do
        { 1 => 2, :symbol => 3, nil => 4 }
      end

      it "does not alter the hash" do
        expect(subject).to eql({ 1 => 2, :symbol => 3, nil => 4 })
      end

    end

  end

  describe "#with_indifferent_and_insensitive_access" do

    let(:hash)                             { { key: "value" } }
    let(:indifferent_and_insensitive_hash) do
      instance_double(HttpStub::Extensions::Core::Hash::WithIndifferentAndInsensitiveAccess)
    end

    subject { hash.with_indifferent_and_insensitive_access }

    before(:example) do
      allow(HttpStub::Extensions::Core::Hash::WithIndifferentAndInsensitiveAccess).to(
        receive(:new).and_return(indifferent_and_insensitive_hash)
      )
    end

    it "creates a hash with indifferent and insensitive access containing the current hash" do
      expect(HttpStub::Extensions::Core::Hash::WithIndifferentAndInsensitiveAccess).to receive(:new).with(hash)

      subject
    end

    it "returns the created hash" do
      expect(subject).to eql(indifferent_and_insensitive_hash)
    end

  end

end
