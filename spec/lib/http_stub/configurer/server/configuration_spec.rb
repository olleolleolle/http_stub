describe HttpStub::Configurer::Server::Configuration do

  let(:configuration) { described_class.new }

  shared_context "a configuration with host and port configured" do

    before(:example) do
      configuration.host = "some_host"
      configuration.port =  8888
    end

  end

  describe "#session_identifier" do

    let(:session_identifier) { { headers: :some_session_identifier } }

    subject { configuration.session_identifier }

    before(:example) { configuration.session_identifier = session_identifier }

    it "returns any configured value" do
      expect(subject).to eql(session_identifier)
    end

  end

  describe "#base_uri" do

    subject { configuration.base_uri }

    include_context "a configuration with host and port configured"

    it "returns a uri that combines any established host and port" do
      expect(subject).to include("some_host:8888")
    end

    it "returns a uri accessed via http" do
      expect(subject).to match(/^http:\/\//)
    end

  end

  describe "#external_base_uri" do

    subject { configuration.external_base_uri }

    include_context "a configuration with host and port configured"

    context "when an external base URI environment variable is established" do

      let(:external_base_uri) { "http://some/external/base/uri" }

      before(:example) { ENV["STUB_EXTERNAL_BASE_URI"] = external_base_uri }
      after(:example)  { ENV["STUB_EXTERNAL_BASE_URI"] = nil }

      it "returns the environment variable" do
        expect(subject).to eql(external_base_uri)
      end

    end

    context "when an external base URI environment variable is not established" do

      it "returns the base URI" do
        expect(subject).to eql(configuration.base_uri)
      end

    end

    it "returns a uri that combines any established host and port" do
      expect(subject).to include("some_host:8888")
    end

    it "returns a uri accessed via http" do
      expect(subject).to match(/^http:\/\//)
    end

  end

  describe "#enable" do

    context "when a feature is provided" do

      let(:feature) { :some_feature }

      subject { configuration.enable(feature) }

      it "enables the feature" do
        subject

        expect(configuration.enabled?(feature)).to be(true)
      end

    end

    context "when features are provided" do

      let(:features) { (1..3).map { |i| "feature_#{i}".to_sym } }

      subject { configuration.enable(*features) }

      it "enables the features" do
        subject

        features.each { |feature| expect(configuration.enabled?(feature)).to be(true) }
      end

    end

  end

  describe "#enabled?" do

    let(:feature) { :some_feature }

    subject { configuration.enabled?(feature) }

    context "when a feature is enabled" do

      before(:example) { configuration.enable(feature) }

      it "returns false" do
        expect(subject).to be(true)
      end

    end

    context "when a feature is not enabled" do

      it "returns false" do
        expect(subject).to be(false)
      end

    end

  end

end
