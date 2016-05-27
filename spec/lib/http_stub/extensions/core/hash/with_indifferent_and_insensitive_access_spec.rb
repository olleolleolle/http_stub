describe HttpStub::Extensions::Core::Hash::WithIndifferentAndInsensitiveAccess do

  let(:hash_with_indifferent_and_insensitive_access) { described_class.new }

  it "is a Hash" do
    expect(hash_with_indifferent_and_insensitive_access).to be_a(::Hash)
  end

  it "has IndifferentAndInsensitiveAccess" do
    expect(hash_with_indifferent_and_insensitive_access).to(
      be_a(HttpStub::Extensions::Core::Hash::IndifferentAndInsensitiveAccess)
    )
  end

  describe "constructor" do

    let(:hash_with_indifferent_and_insensitive_access) { described_class.new(existing_hash) }

    context "when provided an existing hash" do

      let(:existing_hash) { { key: :value } }

      it "creates an indifferent and insensitive hash that includes the entries from the provided hash" do
        expect(hash_with_indifferent_and_insensitive_access).to include(existing_hash)
      end

    end

    context "when provided nil" do

      let(:existing_hash) { nil }

      it "creates an empty indifferent and insensitive hash" do
        expect(hash_with_indifferent_and_insensitive_access.empty?).to be(true)
      end

    end

  end

end
