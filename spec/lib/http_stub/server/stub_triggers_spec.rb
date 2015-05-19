describe HttpStub::Server::StubTriggers do

  let(:trigger_bodies)     { (1..3).map { |i| "trigger body #{i}" } }
  let(:stubs_for_triggers) { (1..trigger_bodies.length).map { instance_double(HttpStub::Server::Stub) } }
  let(:stub_triggers)      { HttpStub::Server::StubTriggers.new(trigger_bodies) }

  before(:example) do
    allow(HttpStub::Server::Stub).to receive(:new).and_return(*stubs_for_triggers)
  end

  describe "constructor" do

    it "creates a stub for each provided trigger" do
      trigger_bodies.zip(stubs_for_triggers).each do |body, stub|
        expect(HttpStub::Server::Stub).to receive(:new).with(body).and_return(stub)
      end

      stub_triggers
    end

  end

  describe "#add_to" do

    let(:registry) { instance_double(HttpStub::Server::StubRegistry) }
    let(:request)  { instance_double("HttpRequest") }

    it "adds each stub to the provided registry" do
      stubs_for_triggers.each { |stub_for_trigger| expect(registry).to receive(:add).with(stub_for_trigger, request) }

      stub_triggers.add_to(registry, request)
    end

  end

  describe "#clear" do

    it "clears each stub" do
      stubs_for_triggers.each { |stub| expect(stub).to receive(:clear) }

      stub_triggers.clear
    end

  end

  describe "#each" do

    it "yields to the stubs for each trigger" do
      yielded_stubs = stub_triggers.each.map.to_a

      expect(yielded_stubs).to eql(stubs_for_triggers)
    end

  end

  describe "#to_s" do

    let(:trigger_strings) { (1..stubs_for_triggers.length).map { |i| "trigger string ##{i}" } }

    before(:example) do
      stubs_for_triggers.zip(trigger_strings).each do |stub_for_trigger, string|
        allow(stub_for_trigger).to receive(:to_s).and_return(string)
      end
    end

    it "should contain a string representation of each trigger" do
      result = stub_triggers.to_s

      trigger_strings.each { |trigger_string| expect(result).to include(trigger_string) }
    end

  end

end
