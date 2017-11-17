describe HttpStub::Server::Stub::Registry, "integrating with real stubs" do

  let(:initial_stubs) { [] }

  let(:logger) { instance_double(Logger, info: nil) }

  let(:stub_registry) { HttpStub::Server::Stub::Registry.new(initial_stubs) }

  shared_context "a stub is added" do

    let(:added_stub) { HttpStub::Server::StubFixture.create(id: 4) }

    before(:example) { stub_registry.add(added_stub, logger) }

  end

  describe "#reset" do

    subject { stub_registry.reset(logger) }

    context "when initial stubs were provided" do

      let(:initial_stubs) { (1..3).map { |i| HttpStub::Server::StubFixture.create(id: i) } }

      context "and a stub is subsequently added" do

        include_context "a stub is added"

        it "retains the initial stubs" do
          subject

          expect(stub_registry.all).to include(*initial_stubs)
        end

        it "rejects stubs not initially present" do
          subject

          expect(stub_registry.all).not_to include(added_stub)
        end

      end

    end

    context "when no initial stubs were provided" do

      let(:initial_stubs) { [] }

      context "and a stub is subsequently added" do

        include_context "a stub is added"

        it "clears the stubs" do
          subject

          expect(stub_registry.all).to eql([])
        end

      end

    end

  end

end
