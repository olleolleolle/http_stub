describe HttpStub::Configurer::DSL::RequestAttributeReferencer do

  let(:attribute_type) { :some_attribute_type }

  let(:request_attribute_referencer) { described_class.new(attribute_type) }

  describe "#[]" do

    let(:name) { "some_name" }

    subject { request_attribute_referencer[name] }

    it "returns a control value" do
      expect(subject).to start_with("control:")
    end

    it "returns a string referring to the referencer request attribute type" do
      expect(subject).to include("request.some_attribute_type")
    end

    it "returns a string that will resolve the value for the provided name" do
      expect(subject).to end_with("[#{name}]")
    end

    context "when the name provided is a symbol" do

      let(:name) { :some_name }

      it "returns a string that resolves the value with the provided name" do
        expect(subject).to end_with("[#{name}]")
      end

    end

  end

end
