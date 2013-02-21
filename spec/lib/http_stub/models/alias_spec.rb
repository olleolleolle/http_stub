describe HttpStub::Models::Alias do

  let(:alias_uri) { "/some/alias/uri" }
  let(:alias_body) do
    { "alias_uri" => alias_uri }.to_json
  end
  let(:the_alias) { HttpStub::Models::Alias.new(alias_body) }

  before(:each) { HttpStub::Models::Stub.stub!(:new).and_return(double(HttpStub::Models::Stub)) }

  describe "#satisfies?" do

    let(:request) { double("HttpRequest", path_info: request_path_info) }

    describe "when the request uri exactly matches the aliases activation uri" do

      let(:request_path_info) { alias_uri }

      it "should return true" do
        the_alias.satisfies?(request).should be_true
      end

    end

    describe "when the alias activation uri is a substring of the request uri" do

      let(:request_path_info) { "#{alias_uri}/with/additional/paths" }

      it "should return false" do
        the_alias.satisfies?(request).should be_false
      end

    end

    describe "when the request uri is completely different to the aliases activation uri" do

      let(:request_path_info) { "/completely/different/path" }

      it "should return false" do
        the_alias.satisfies?(request).should be_false
      end

    end

  end

  describe "#the_stub" do

    it "should return a HttpStub::Models::Stub constructed from the request body" do
      stub = double(HttpStub::Models::Stub)
      HttpStub::Models::Stub.should_receive(:new).with(alias_body).and_return(stub)

      the_alias.the_stub.should eql(stub)
    end

  end

end
