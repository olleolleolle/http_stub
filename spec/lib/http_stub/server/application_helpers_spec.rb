describe HttpStub::Server::ApplicationHelpers do


  let(:instance) { Class.new.send(:include, described_class).new }

  describe '::h' do
    let(:text) { '<tag>Some text</tag>' }
    subject do
      instance.h(text)
    end

    it 'should escape the provided HTML' do
      expect(subject).to eq('&lt;tag&gt;Some text&lt;&#x2F;tag&gt;')
    end
  end

  describe '::pretty_text' do
    it 'should return empty string if no text provided' do
      expect(instance.pretty_text(nil)).to eq("")
    end

    it 'should return the string if the string is not JSON' do
      expect(instance.pretty_text("some text")).to eq("some text")
    end

    it 'should return a pretty JSON string if the text is JSON' do
      expect(instance.pretty_text('{"key":"value"}')).to eq("{\n  \"key\": \"value\"\n}")
    end
  end

end
