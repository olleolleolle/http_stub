describe HttpStub::Controllers::AliasController do

  let(:request_body) { "Some request body" }
  let(:request) { double("HttpRequest", body: double("RequestBody", read: request_body)) }
  let(:the_stub) { double(HttpStub::Models::Stub) }
  let(:stub_alias) { double(HttpStub::Models::Alias, the_stub: the_stub) }
  let(:alias_registry) { double("HttpStub::Models::AliasRegistry").as_null_object }
  let(:stub_registry) { double("HttpStub::Models::StubRegistry").as_null_object }
  let(:controller) { HttpStub::Controllers::AliasController.new(alias_registry, stub_registry) }

  describe "#register" do

    before(:each) do
      HttpStub::Models::Alias.stub!(:new).and_return(stub_alias)
    end

    it "should create an alias from the request body" do
      HttpStub::Models::Alias.should_receive(:new).with(request_body).and_return(stub_alias)

      controller.register(request)
    end

    it "should add the created alias to the alias registry" do
      alias_registry.should_receive(:add).with(stub_alias, request)

      controller.register(request)
    end

    it "should return a success response" do
      controller.register(request).should eql(HttpStub::Response::SUCCESS)
    end

  end

  describe "#activate" do

    describe "when an alias has been registered that is activated by the request" do

      before(:each) do
        alias_registry.stub!(:find_for).with(request).and_return(stub_alias)
      end

      it "should add the aliases stub to the stub registry" do
        stub_registry.should_receive(:add).with(the_stub, request)

        controller.activate(request)
      end

      it "should return a success response" do
        controller.activate(request).should eql(HttpStub::Response::SUCCESS)
      end

    end

    describe "when no alias is activated by the request" do

      before(:each) do
        alias_registry.stub!(:find_for).with(request).and_return(nil)
      end

      it "should not add a stub to the registry" do
        stub_registry.should_not_receive(:add)

        controller.activate(request)
      end

      it "should return an empty response" do
        controller.activate(request).should eql(HttpStub::Response::EMPTY)
      end

    end

  end

end
