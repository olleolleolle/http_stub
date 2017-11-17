describe HttpStub::Server::Registry do

  let(:model_name) { "a_model" }

  let(:logger) { instance_double(Logger, info: nil) }

  let(:registry) { described_class.new(model_name) }

  shared_context "multiple models" do

    let(:models) { (1..3).map { |i| double("HttpStub::Server::Model#{i}", matches?: false) } }

  end

  shared_context "register multiple models" do
    include_context "multiple models"

    before(:example) { registry.concat(models, logger) }

  end

  shared_context "one model matches" do

    let(:matching_model) { models[1] }

    before(:example) { allow(matching_model).to receive(:matches?).and_return(true) }

  end

  shared_context "many models match" do

    let(:matching_models) { [ models[0], models[2] ] }

    before(:example) { matching_models.each { |model| allow(model).to receive(:matches?).and_return(true) } }

  end

  describe "constructor" do

    context "when models are provided" do
      include_context "multiple models"

      subject { described_class.new(model_name, models) }

      it "creates a registry with the models in reverse order as the registry operates akin to a stack" do
        registry = subject

        expect(registry.all).to eql(models.reverse)
      end

    end

    context "when models are not provided" do

      subject { described_class.new(model_name) }

      it "creates a registy with no models" do
        expect(subject.all).to eql([])
      end

    end

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

    it "adds the models" do
      subject

      expect_registry_to_contain(models)
    end

    it "logs that the models have been registered" do
      model_string_representations.each do |string_representation|
        expect(logger).to receive(:info).with(/Registered.+#{string_representation}/)
      end

      subject
    end

  end

  describe "#replace" do

    let(:model_string_representations) { (1..3).map { |i| "model string ##{i}" } }
    let(:models) do
      model_string_representations.map do |string_representation|
        double("HttpStub::Server::Model", to_s: string_representation)
      end
    end

    subject { registry.replace(models, logger) }

    context "when no models had been added" do

      it "establishes the models" do
        subject

        expect_registry_to_contain(models)
      end

    end

    context "when models had been added" do

      let(:original_models) { (1..3).map { double("HttpStub::Server::Model") } }

      before(:example) { registry.concat(original_models, logger) }

      it "replaces those models with the provided models" do
        subject

        expect_registry_to_contain(models)
      end

    end

    it "logs that the models are being cleared" do
      expect(logger).to receive(:info).with(/clearing a_model/i)

      subject
    end

    it "logs that the models have been registered" do
      model_string_representations.each do |string_representation|
        expect(logger).to receive(:info).with(/Registered.+#{string_representation}/)
      end

      subject
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
        include_context "one model matches"

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
        include_context "many models match"

        it "supports model overrides by returning the last model registered" do
          expect(subject).to eql(matching_models.last)
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

    it "logs model discovery diagnostics that include the complete details of the criteria" do
      expect(logger).to receive(:info).with(/Criteria inspect result/)

      subject
    end

  end

  describe "#find_all" do

    subject { registry.find_all(&condition) }

    context "when multiple models have been registered" do
      include_context "register multiple models"

      let(:condition) { lambda { |model| matching_models.include?(model) } }

      context "when many models match the condition" do

        let(:matching_models) { [ models.first, models.last ] }

        it "returns the models preserving stack order" do
          expect(subject).to eql(matching_models.reverse)
        end

      end

      context "when one model matches the condition" do

        let(:matching_models) { [ models[1] ] }

        it "returns an array containing the model" do
          expect(subject).to eql(matching_models)
        end

      end

      context "when no model matches the condition" do

        let(:matching_models) { [] }

        it "returns an empty array" do
          expect(subject).to eql([])
        end

      end

    end

    context "when no models have been registered" do

      let(:condition) { lambda { |_| true } }

      it "returns an empty array" do
        expect(subject).to eql([])
      end

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
        expect_registry_to_contain(models)
      end

    end

    context "when no model has been registered" do

      it "returns an empty list" do
        expect_registry_to_contain([])
      end

    end

  end

  describe "#delete" do

    let(:criteria) { double("Criteria", inspect: "Criteria inspect result") }

    subject { registry.delete(criteria, logger) }

    context "when multiple models have been registered" do
      include_context "register multiple models"

      it "determines if the models satisfy the provided criteria" do
        models.each { |model| expect(model).to receive(:matches?).with(criteria, logger).and_return(false) }

        subject
      end

      context "when the criteria matches a model" do
        include_context "one model matches"

        it "deletes the matched model from the registry" do
          subject

          expect_registry_to_contain(models - [ matching_model ])
        end

      end

      context "when the criteria matches many models" do
        include_context "many models match"

        it "deletes all matching models" do
          subject

          expect_registry_to_contain(models - matching_models)
        end

      end

      context "when the criteria does not match any model" do

        it "does not delete any models" do
          subject

          expect_registry_to_contain(models)
        end

      end

    end

    context "when no model has been registered" do

      it "does not delete any models" do
        subject

        expect_registry_to_contain([])
      end

    end

    it "logs model deletion diagnostics that include the complete details of the criteria" do
      expect(logger).to receive(:info).with(/Criteria inspect result/)

      subject
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

        expect_registry_to_contain([])
      end

    end

  end

  def expect_registry_to_contain(models)
    expect(registry.all).to eql(models.reverse)
  end

end
