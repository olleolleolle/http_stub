describe HttpStub::Server::Stub::Registry, "integrating with real stubs" do

  let(:memory_session) { HttpStub::Server::SessionFixture.memory }

  let(:logger) { instance_double(Logger, info: nil) }

  let(:stub_registry) { HttpStub::Server::Stub::Registry.new(memory_session) }

  shared_context "a stub is added" do

    let(:added_stub) { create_stub(4) }

    before(:example) { stub_registry.add(added_stub, logger) }

  end

  describe "#reset" do

    subject { stub_registry.reset(logger) }

    context "when stubs have been added to the servers memory" do

      let(:stubs) { (1..3).map { |i| create_stub(i) } }

      before(:example) { stubs.each { |stub| memory_session.add_stub(stub, logger) } }

      context "and a stub is subsequently added" do

        include_context "a stub is added"

        it "retains stubs added to the servers memory" do
          subject

          expect(stub_registry.all).to eql(stubs)
        end

        it "rejects stubs not added to the servers memory" do
          subject

          expect(stub_registry.all).not_to include(added_stub)
        end

      end

    end

    context "when no stubs have been added to the servers memory" do

      context "and a stub is subsequently added" do

        include_context "a stub is added"

        it "clears the stubs" do
          subject

          expect(stub_registry.all).to eql([])
        end

      end

    end

  end

  def create_stub(number)
    HttpStub::Server::Stub.create(
      "uri" => "/uri#{number}",
      "method" => "get",
      "headers" => {"header_key_#{number}" => "header_value_#{number}"},
      "parameters" => {"parameter_key_#{number}" => "parameter_value_#{number}"},
      "response" => {
        "status" => 200 + number,
        "body" => "Body #{number}"
      },
      "triggers" => {
        "scenario_names" => [],
        "stubs"          => []
      }
    )
  end

end
