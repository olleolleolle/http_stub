describe HttpStub::Extensions::Core::Object do

  it "patches ::Object" do
    expect(::Object.included_modules).to include(described_class)
  end

  describe "#short_class_name" do

    subject { object.short_class_name }

    context "when a class name is a single word" do

      it "returns the name in lower case" do
        
      end

    end

    context "when a class name contains many words" do

      it "combines the words with an underscore" do
        
      end

    end

  end

end
