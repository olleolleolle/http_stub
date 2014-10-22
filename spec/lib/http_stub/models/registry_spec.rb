describe HttpStub::Models::Registry do

  let(:logger)  { double("Logger").as_null_object }
  let(:request) { double("HttpRequest", logger: logger, inspect: "Request inspect result") }

  let(:registry) { HttpStub::Models::Registry.new("a_model") }

  describe "#add" do

    it "logs that the model has been registered" do
      model = double("HttpStub::Models::Model", to_s: "Model as String")
      expect(logger).to receive(:info).with(/Model as String/)

      registry.add(model, request)
    end

  end

  describe "#find_for" do

    describe "when multiple models have been registered" do

      let(:models) do
        (1..3).map { |i| double("HttpStub::Models::Model#{i}", :satisfies? => false) }
      end

      before(:example) do
        models.each { |model| registry.add(model, request) }
      end

      describe "and one registered model satisfies the request" do

        let(:matching_model) { models[1] }

        before(:example) { allow(matching_model).to receive(:satisfies?).and_return(true) }

        it "returns the model" do
          expect(registry.find_for(request)).to eql(matching_model)
        end

        describe "and the registry is subsequently cleared" do

          before(:example) { registry.clear(request) }

          it "returns nil" do
            expect(registry.find_for(request)).to be_nil
          end

        end

      end

      describe "and multiple registered models satisfy the request" do

        before(:example) do
          [0, 2].each { |i| allow(models[i]).to receive(:satisfies?).and_return(true) }
        end

        it "supports model overrides by returning the last model registered" do
          expect(registry.find_for(request)).to eql(models[2])
        end

      end

      describe "and no registered models match the request" do

        it "returns nil" do
          expect(registry.find_for(request)).to be_nil
        end

      end

    end

    describe "when no model has been registered" do

      it "returns nil" do
        expect(registry.find_for(request)).to be_nil
      end

    end

    it "it should log model discovery diagnostics that includes the complete details of the request" do
      expect(logger).to receive(:info).with(/Request inspect result/)

      registry.find_for(request)
    end

  end

  describe "#all" do

    describe "when multiple models have been registered" do

      let(:models) do
        (1..3).map { |i| double("HttpStub::Models::Model#{i}", :satisfies? => false) }
      end

      before(:example) do
        models.each { |model| registry.add(model, request) }
      end

      it "returns the registered models in the order they were added" do
        expect(registry.all).to eql(models.reverse)
      end

    end

    describe "when no model has been registered" do

      it "returns an empty list" do
        expect(registry.all).to eql([])
      end

    end

  end

  describe "#copy" do

    class HttpStub::Models::CopyableModel

      attr_reader :name

      def initialize(name)
        @name = name
      end

      def eql?(other)
        @name = other.name
      end

    end

    subject { registry.copy }

    context "when multiple models have been registered" do

      let(:models) { (1..3).map { |i| HttpStub::Models::CopyableModel.new("model_#{i}") } }

      before(:each) { models.each { |model| registry.add(model, request) } }

      it "returns a registry containing the models" do
        result = subject

        expect(result.all).to eql(models)
      end

    end

    it "returns a registry that changes independently of the copied registry" do
      model_to_add = HttpStub::Models::CopyableModel.new("model_to_add")

      result = subject

      registry.add(model_to_add, request)
      expect(result.all).not_to include(model_to_add)
    end

  end

  describe "#clear" do

    it "logs that the models are being cleared" do
      expect(logger).to receive(:info).with(/clearing a_model/i)

      registry.clear(request)
    end

  end

end
