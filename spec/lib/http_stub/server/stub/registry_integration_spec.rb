describe HttpStub::Server::Stub::Registry, "integrating with real stubs" do

  let(:logger) { instance_double(Logger, info: nil) }

  let(:stub_registry) { HttpStub::Server::Stub::Registry.new }

  describe "#recall" do

    subject { stub_registry.recall }

    context "when stubs have been added" do

      let(:stubs) { (1..3).map { |i| create_stub(i) } }

      before(:example) { stubs.each { |stub| stub_registry.add(stub, logger) } }

      context "and remembered" do

        before(:example) { stub_registry.remember }

        context "and a stub subsequently added" do

          let(:stub_to_add) { create_stub(4) }

          before(:example) { stub_registry.add(stub_to_add, logger) }

          it "should restore all known stubs to the remembered state" do
            subject

            expect(stub_registry.all).not_to include(stub_to_add)
          end

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
