describe HttpStub::Controllers::AliasController do

  let(:request_body) { "Some request body" }
  let(:request) { double("HttpRequest", body: double("RequestBody", read: request_body)) }
  let(:alias_options) { double("AliasOptions") }
  let(:the_stub) { double(HttpStub::Models::Stub) }
  let(:the_alias) { double(HttpStub::Models::Alias, the_stub: the_stub) }
  let(:alias_registry) { double("HttpStub::Models::AliasRegistry").as_null_object }
  let(:stub_registry) { double("HttpStub::Models::StubRegistry").as_null_object }
  let(:controller) { HttpStub::Controllers::AliasController.new(alias_registry, stub_registry) }

  before(:each) { JSON.stub!(:parse).and_return(alias_options) }

  describe "#list" do

    describe "when the alias registry contains multiple aliases" do

      before(:each) do
        alias_registry.stub!(:all).and_return((1..3).map { |i| double("#{HttpStub::Models::Alias}#{i}") })
      end

      it "should return a page containing each alias" do

      end

    end

    describe "when the alias registry contains one alias" do

      it "should return a page containing the one alias" do

      end

    end

    describe "when then alias registry is empty" do

      it "should return an empty page" do

      end

    end

  end

  describe "#register" do

    before(:each) do
      HttpStub::Models::Alias.stub!(:new).and_return(the_alias)
    end

    it "should parse an options hash from the JSON request body" do
      JSON.should_receive(:parse).with(request_body).and_return(alias_options)

      controller.register(request)
    end

    it "should create an alias from the parsed options" do
      HttpStub::Models::Alias.should_receive(:new).with(alias_options).and_return(the_alias)

      controller.register(request)
    end

    it "should add the created alias to the alias registry" do
      alias_registry.should_receive(:add).with(the_alias, request)

      controller.register(request)
    end

    it "should return a success response" do
      controller.register(request).should eql(HttpStub::Response::SUCCESS)
    end

  end

  describe "#activate" do

    describe "when an alias has been registered that is activated by the request" do

      before(:each) do
        alias_registry.stub!(:find_for).with(request).and_return(the_alias)
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

  describe "#clear" do

    it "should clear the alias registry" do
      alias_registry.should_receive(:clear).with(request)

      controller.clear(request)
    end

  end

end
