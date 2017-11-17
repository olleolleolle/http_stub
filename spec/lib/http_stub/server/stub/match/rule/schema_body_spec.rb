describe HttpStub::Server::Stub::Match::Rule::SchemaBody do

  class HttpStub::Server::Stub::Match::Rule::TestSchemaBody

    attr_reader :definition

    def initialize(definition)
      @definition = definition
    end

  end

  describe "::create" do

    subject { described_class.create(args) }

    context "when a supported type is specified" do

      let(:definition) { "some definition" }
      let(:args)       { { type: :test, definition: "some definition" } }

      it "creates a schema body of the specified type" do
        expect(subject).to be_an_instance_of(HttpStub::Server::Stub::Match::Rule::TestSchemaBody)
      end

      it "creates a body with the specified definition" do
        expect(subject.definition).to eql(definition)
      end

    end

    context "when an unsupported type is specified" do

      let(:args) { { type: :not_supported, definition: "some definition" } }

      it "raises an error indicating the schema type is not supported" do
        expect { subject }.to raise_error(/not_supported schema is not supported/)
      end

    end

    context "when the schema type is not specified" do

      let(:args) { { definition: "some definition" } }

      it "raises an error indicating the type is mandatory" do
        expect { subject }.to raise_error(/type expected/)
      end

    end

    context "when the schema definition is not specified" do

      let(:args) { { type: :test } }

      it "raises an error indicating the type is mandatory" do
        expect { subject }.to raise_error(/definition expected/)
      end

    end

  end

end
