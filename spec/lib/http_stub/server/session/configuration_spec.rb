describe HttpStub::Server::Session::Configuration do

  let(:identifier_setting) { nil }

  let(:configuration) { described_class.new(identifier_setting) }

  describe "#identifer_configuration" do

    subject { configuration.identifier_configuration }

    shared_examples_for "an identifier configuration starting with the default configuration" do

      it "has the http_stub session id parameter as the first entry" do
        expect(subject.first).to eql(parameter: :http_stub_session_id)
      end

      it "has the http_stub session id header as the second entry" do
        expect(subject[1]).to eql(header: :http_stub_session_id)
      end

    end

    context "when a setting is provided" do

      let(:identifier_setting) { { header: :custom_session_header } }

      it_behaves_like "an identifier configuration starting with the default configuration"

      it "returns a configuration containing the setting as the last entry" do
        expect(subject.last).to eql(header: :custom_session_header)
      end

      it "returns a configuration containing only the default settings and the provided setting" do
        expect(subject.size).to eql(3)
      end

    end

    context "when no setting is provided" do

      let(:identifier_setting) { nil }

      it_behaves_like "an identifier configuration starting with the default configuration"

      it "returns a configuration containing only the default settings" do
        expect(subject.size).to eql(2)
      end

    end

  end

  describe "#default_identifier" do

    subject { configuration.default_identifier }

    it "has an original value that is the memory session id" do
      expect(subject).to eql(HttpStub::Server::Session::MEMORY_SESSION_ID)
    end

    context "when changed" do

      let(:new_identifier) { "some other identifier" }

      before(:example) { configuration.default_identifier = new_identifier }

      it "returns the newly assigned value" do
        expect(subject).to eql(new_identifier)
      end

    end

  end

  describe "#reset" do

    subject { configuration.reset }

    context "when the default indentifier has changed" do

      before(:example) { configuration.default_identifier = "some other identifier" }

      it "reverts the default identifier to it's original value" do
        subject

        expect(configuration.default_identifier).to eql(HttpStub::Server::Session::MEMORY_SESSION_ID)

      end

    end

  end

end
