describe HttpStub::Server::ApplicationHelpers do

  let(:helpers) { Class.new.include(described_class).new }

  describe "::h" do

    let(:text) { "<tag>Some text</tag>" }

    subject { helpers.h(text) }

    it "should escape the provided HTML" do
      expect(subject).to eq("&lt;tag&gt;Some text&lt;&#x2F;tag&gt;")
    end

  end

  describe "::pp" do

    subject { helpers.pp(text) }

    context "when the text is JSON" do

      let(:text) { "{\"key\":\"value\"}" }

      it "returns a pretty JSON string" do
        expect(subject).to eql("{\n  \"key\": \"value\"\n}")
      end

    end

    context "when the text is not JSON" do

      let(:text) { "some text" }

      it "returns the string unchanged" do
        expect(subject).to eql(text)
      end

    end

    context "when the text is nil" do

      let(:text) { nil }

      it "returns an empty string" do
        expect(subject).to eql("")
      end

    end

  end

end
