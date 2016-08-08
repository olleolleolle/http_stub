describe HttpStub::Server::Stub::Empty do

  let(:empty_stub) { HttpStub::Server::Stub::Empty::INSTANCE }

  describe "#uri" do

    it "is an empty string" do
      expect(empty_stub.uri).to eql("")
    end

  end

  describe "#match_rules" do

    it "is empty" do
      expect(empty_stub.match_rules).to eql(HttpStub::Server::Stub::Match::Rules::EMPTY)
    end

  end

  describe "#triggers" do

    it "is an empty array" do
      expect(empty_stub.triggers).to eql([])
    end

  end

  describe "#response" do

    it "is empty" do
      expect(empty_stub.response).to eql(HttpStub::Server::Response::EMPTY)
    end

  end

  describe "#matches?" do

    let(:criteria) { double("MatchCriteria") }
    let(:logger)   { instance_double(Logger) }

    it "returns false" do
      expect(empty_stub.matches?(criteria, logger)).to eql(false)
    end

  end

  describe "#response_for" do

    let(:request) { instance_double(HttpStub::Server::Request) }

    it "returns unchanged empty stub" do
      expect(empty_stub.response_for(request)).to eql(empty_stub)
    end

  end

  describe "#to_hash" do

    it "returns an empty hash" do
      expect(empty_stub.to_hash).to eql({})
    end

  end

  describe "#to_s" do

    it "returns an empty string" do
      expect(empty_stub.to_s).to eql("")
    end

  end

  it "defines all the methods on a convetional Stub" do
    expect(HttpStub::Server::Stub::Empty.instance_methods).to include(*HttpStub::Server::Stub::Stub.instance_methods)
  end

end
