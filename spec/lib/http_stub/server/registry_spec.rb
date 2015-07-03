describe HttpStub::Server::Registry do

  let(:logger)  { instance_double(Logger, info: nil) }

  let(:registry) { HttpStub::Server::Registry.new("a_model") }

  shared_context "register multiple models" do

    let(:models) { (1..3).map { |i| double("HttpStub::Server::Model#{i}", :matches? => false) } }

    before(:example) { registry.concat(models, logger) }

  end

  describe "#add" do

    let(:model_string_representation) { "some model string" }
    let(:model)                       { double("HttpStub::Server::Model", to_s: model_string_representation) }

    subject { registry.add(model, logger) }

    before(:example) { allow(logger).to receive(:info) }

    it "logs that the model has been registered" do
      expect(logger).to receive(:info).with(/#{model_string_representation}/)

      subject
    end

    it "adds the model" do
      subject

      expect(registry.last).to eql(model)
    end

  end

  describe "#concat" do

    let(:model_string_representations) { (1..3).map { |i| "model string ##{i}" } }
    let(:models) do
      model_string_representations.map do |string_representation|
        double("HttpStub::Server::Model", to_s: string_representation)
      end
    end

    subject { registry.concat(models, logger) }

    it "logs that the models have been registered" do
      model_string_representations.each do |string_representation|
        expect(logger).to receive(:info).with(/#{string_representation}/)
      end

      subject
    end

    it "adds the models" do
      subject

      expect(registry.all).to eql(models.reverse)
    end

  end

  describe "#find" do

    let(:criteria) { double("Criteria", inspect: "Criteria inspect result") }

    subject { registry.find(criteria, logger) }

    describe "when multiple models have been registered" do

      include_context "register multiple models"

      it "determines if the models satisfy the provided criteria" do
        models.each { |model| expect(model).to receive(:matches?).with(criteria, logger).and_return(false) }

        subject
      end

      describe "and one registered model matches the criteria" do

        let(:matching_model) { models[1] }

        before(:example) { allow(matching_model).to receive(:matches?).and_return(true) }

        it "returns the model" do
          expect(subject).to eql(matching_model)
        end

        describe "and the registry is subsequently cleared" do

          before(:example) { registry.clear(logger) }

          it "returns nil" do
            expect(subject).to be_nil
          end

        end

      end

      describe "and multiple registered models satisfy the criteria" do

        before(:example) { [0, 2].each { |i| allow(models[i]).to receive(:matches?).and_return(true) } }

        it "supports model overrides by returning the last model registered" do
          expect(subject).to eql(models[2])
        end

      end

      describe "and no registered models match the criteria" do

        it "returns nil" do
          expect(subject).to be_nil
        end

      end

    end

    describe "when no model has been registered" do

      it "returns nil" do
        expect(subject).to be_nil
      end

    end

    it "it should log model discovery diagnostics that includes the complete details of the criteria" do
      expect(logger).to receive(:info).with(/Criteria inspect result/)

      subject
    end

  end

  describe "#last" do

    context "when multiple models have been registered" do

      include_context "register multiple models"

      it "returns the last added model" do
        expect(registry.last).to eql(models.last)
      end

    end

    context "when a model has been registered" do

      let(:model) { double("HttpStub::Server::Model") }

      before(:example) { registry.add(model, logger) }

      it "returns the model" do
        expect(registry.last).to eql(model)
      end

    end

  end

  describe "#all" do

    context "when multiple models have been registered" do

      include_context "register multiple models"

      it "returns the registered models in the order they were added" do
        expect(registry.all).to eql(models.reverse)
      end

    end

    context "when no model has been registered" do

      it "returns an empty list" do
        expect(registry.all).to eql([])
      end

    end

  end

  describe "#rollback_to" do

    subject { registry.rollback_to(model) }

    context "when models have been added" do

      include_context "register multiple models"

      context "and the rollback is to one of those models" do

        let(:model) { models[1] }

        it "the models remaining are those added up to and including the provided model" do
          subject

          expect(registry.all).to eql(models[0, 2].reverse)
        end

      end

      context "and the rollback is to a model that has not been added" do

        let(:model) { double("HttpStub::Server::Model") }

        it "does not remove any models" do
          subject

          expect(registry.all).to eql(models.reverse)
        end

      end

    end

    context "when no models have been added" do

      let(:model) { double("HttpStub::Server::Model") }

      it "does not effect the known models" do
        subject

        expect(registry.all).to be_empty
      end

    end

  end

  describe "#clear" do

    subject { registry.clear(logger) }

    it "logs that the models are being cleared" do
      expect(logger).to receive(:info).with(/clearing a_model/i)

      subject
    end

    context "when models have been added" do

      include_context "register multiple models"

      it "releases all knowledge of the models" do
        subject

        expect(registry.all).to be_empty
      end

    end

  end

end
