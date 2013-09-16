describe HttpStub::Models::Registry do

  let(:registry) { HttpStub::Models::Registry.new("a_model") }

  let(:logger) { double("Logger").as_null_object }
  let(:request) { double("HttpRequest", logger: logger, inspect: "Request inspect result") }

  describe "#add" do

    it "should log that the model has been registered" do
      model = double("HttpStub::Models::Model", to_s: "Model as String")
      logger.should_receive(:info).with(/Model as String/)

      registry.add(model, request)
    end

  end

  describe "#find_for" do

    describe "when multiple models have been registered" do

      let(:models) do
        (1..3).map { |i| double("HttpStub::Models::Model#{i}", :satisfies? => false) }
      end

      before(:each) do
        models.each { |model| registry.add(model, request) }
      end

      describe "and one registered model satisfies the request" do

        let(:matching_model) { models[1] }

        before(:each) { matching_model.stub(:satisfies?).and_return(true) }

        it "should return the model" do
          registry.find_for(request).should eql(matching_model)
        end

        describe "and the registry is subsequently cleared" do

          before(:each) { registry.clear(request) }

          it "should return nil" do
            registry.find_for(request).should be_nil
          end

        end

      end

      describe "and multiple registered models satisfy the request" do

        before(:each) do
          [0, 2].each { |i| models[i].stub(:satisfies?).and_return(true) }
        end

        it "should support model overrides by returning the last model registered" do
          registry.find_for(request).should eql(models[2])
        end

      end

      describe "and no registered models match the request" do

        it "should return nil" do
          registry.find_for(request).should be_nil
        end

      end

    end

    describe "when no model has been registered" do

      it "should return nil" do
        registry.find_for(request).should be_nil
      end

    end

    it "it should log model discovery diagnostics that includes the complete details of the request" do
      logger.should_receive(:info).with(/Request inspect result/)

      registry.find_for(request)
    end

  end

  describe "#all" do

    describe "when multiple models have been registered" do

      let(:models) do
        (1..3).map { |i| double("HttpStub::Models::Model#{i}", :satisfies? => false) }
      end

      before(:each) do
        models.each { |model| registry.add(model, request) }
      end

      it "should return the registered models in the order they were added" do
        registry.all.should eql(models.reverse)
      end

    end

    describe "when no model has been registered" do

      it "should return an empty list" do
        registry.all.should eql([])
      end

    end

  end

  describe "#clear" do

    it "should log that the models are being cleared" do
      logger.should_receive(:info).with(/clearing a_model/i)

      registry.clear(request)
    end

  end

end
