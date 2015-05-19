describe HttpStub::Server::Registry do

  let(:logger)  { double("Logger").as_null_object }
  let(:request) { double("HttpRequest", logger: logger, inspect: "Request inspect result") }

  let(:registry) { HttpStub::Server::Registry.new("a_model") }

  shared_context "register multiple models" do

    let(:models) { (1..3).map { |i| double("HttpStub::Server::Model#{i}", :satisfies? => false, :clear => nil) } }

    before(:example) { models.each { |model| registry.add(model, request) } }

  end

  describe "#add" do

    it "logs that the model has been registered" do
      model = double("HttpStub::Server::Model", to_s: "Model as String")
      expect(logger).to receive(:info).with(/Model as String/)

      registry.add(model, request)
    end

  end

  describe "#find_for" do

    describe "when multiple models have been registered" do

      include_context "register multiple models"

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

        before(:example) { [0, 2].each { |i| allow(models[i]).to receive(:satisfies?).and_return(true) } }

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

  describe "#last" do

    context "when multiple models have been registered" do

      include_context "register multiple models"

      it "returns the last added model" do
        expect(registry.last).to eql(models.last)
      end

    end

    context "when a model has been registered" do

      let(:model) { double("HttpStub::Server::Model") }

      before(:example) { registry.add(model, request) }

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

  describe "#clear" do

    subject { registry.clear(request) }

    it "logs that the models are being cleared" do
      expect(logger).to receive(:info).with(/clearing a_model/i)

      subject
    end

    context "when models have been added" do

      include_context "register multiple models"

      it "clears each model" do
        models.each { |model| expect(model).to receive(:clear) }

        subject
      end

      it "releases all knowledge of the models" do
        subject

        expect(registry.all).to be_empty
      end

    end

  end

end
