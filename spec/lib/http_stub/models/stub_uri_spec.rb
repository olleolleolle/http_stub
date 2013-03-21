describe HttpStub::Models::StubUri do

  let(:request) { double("HttpRequest", path_info: request_uri) }

  let(:stub_uri) { HttpStub::Models::StubUri.new(stubbed_uri) }

  describe "#match?" do

    describe "when the uri provided has no 'regexp' prefix" do

      let(:stubbed_uri) { "/some/uri" }

      describe "and the request uri is equal" do

        let(:request_uri) { "/some/uri" }

        it "should return true" do
          stub_uri.match?(request).should be_true
        end

      end

      describe "and the request uri is not equal" do

        let(:request_uri) { "/some/other/uri" }

        it "should return false" do
          stub_uri.match?(request).should be_false
        end

      end

    end

    describe "when the uri provided has a 'regexp' prefix" do

      let(:stubbed_uri) { "regexp:/some/regexp/uri/.+" }

      describe "and the request uri matches the regular expression" do

        let(:request_uri) { "/some/regexp/uri/match" }

        it "should return true" do
          stub_uri.match?(request).should be_true
        end

      end

      describe "and the request uri does not match the regular expression" do

        let(:request_uri) { "/some/other/uri" }

        it "should return false" do
          stub_uri.match?(request).should be_false
        end

      end

    end

  end

  describe "#to_s" do

    let(:stubbed_uri) { "some/uri" }

    it "should return the uri" do
      stub_uri.to_s.should eql(stubbed_uri)
    end

  end

end
