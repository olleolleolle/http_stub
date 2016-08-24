describe HttpStub::Server::Session::Factory do

  let(:scenario_registry)     { instance_double(HttpStub::Server::Registry) }
  let(:session_configuration) { { some_configured_key: "some configured value" } }

  let(:identifier_strategy) { instance_double(HttpStub::Server::Session::IdentifierStrategy) }

  let(:factory) { described_class.new(scenario_registry, session_configuration) }

  before(:example) do
    allow(HttpStub::Server::Session::IdentifierStrategy).to receive(:new).and_return(identifier_strategy)
  end

  describe "constructor" do

    subject { factory }

    it "creates a session identifier strategy based on the provided configuration" do
      expect(HttpStub::Server::Session::IdentifierStrategy).to receive(:new).with(session_configuration)

      subject
    end

  end

  describe "#create" do

    let(:request) { create_request }

    subject { factory.create(request) }

    it "determines the session identifier for the request" do
      expect(identifier_strategy).to receive(:identifier_for).with(request)

      subject
    end

    it "returns the same session when the same identifier is determined" do
      allow(identifier_strategy).to receive(:identifier_for).and_return("common identifier")

      expect(factory.create(create_request)).to be(factory.create(create_request))
    end

    it "returns a different session when a different identifier is determined" do
      first_request  = create_request
      second_request = create_request
      allow(identifier_strategy).to receive(:identifier_for).with(first_request).and_return("first identifier")
      allow(identifier_strategy).to receive(:identifier_for).with(second_request).and_return("second identifier")

      expect(factory.create(first_request)).to_not be(factory.create(second_request))
    end

    def create_request
      instance_double(HttpStub::Server::Request::Request)
    end

  end

end
