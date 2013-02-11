describe Http::Stub::Registry do

  let(:registry) { Http::Stub::Registry.new }

  let(:logger) { double("Logger").as_null_object }
  let(:request) { double("HttpRequest", logger: logger, to_s: "Request as String") }

  describe "#add" do

    it "should log that the stub has been registered" do
      stub = double(Http::Stub::Stub, to_s: "Stub as String")
      logger.should_receive(:info).with(/Stub as String/)

      registry.add(stub, request)
    end

  end

  describe "#find_for" do

    describe "when multiple stubs have been registered" do

      let(:stubs) do
        (1..3).map { |i| double("#{Http::Stub::Stub}#{i}", :stubs? => false) }
      end

      before(:each) do
        stubs.each { |stub| registry.add(stub, request) }
      end

      describe "and one registered stub matches the request" do

        before(:each) { stubs[1].stub!(:stubs?).and_return(true) }

        it "should return the stub" do
          registry.find_for(request).should eql(stubs[1])
        end

      end

      describe "and multiple registered stubs match the request" do

        before(:each) do
          [0, 2].each { |i| stubs[i].stub!(:stubs?).and_return(true) }
        end

        it "should support stub overrides by returning the last stub registered" do
          registry.find_for(request).should eql(stubs[2])
        end

      end

      describe "and no registered stubs match the request" do

        it "should return nil" do
          registry.find_for(request).should be_nil
        end

      end

    end

    describe "when no stub has been registered" do

      it "should return nil" do
        registry.find_for(request).should be_nil
      end

    end

    it "it should log that a stub is being found" do
      logger.should_receive(:info).with(/Request as String/)

      registry.find_for(request)
    end

  end

end
