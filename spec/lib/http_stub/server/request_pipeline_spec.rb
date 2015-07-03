describe HttpStub::Server::RequestPipeline do

  let(:stub_controller)     { instance_double(HttpStub::Server::Stub::Controller).as_null_object }
  let(:scenario_controller) { instance_double(HttpStub::Server::Scenario::Controller).as_null_object }
  let(:match_registry)      { instance_double(HttpStub::Server::Stub::Registry).as_null_object }

  let(:request_pipeline) { described_class.new(stub_controller, scenario_controller, match_registry) }

  describe "#process" do

    let(:request) { instance_double(HttpStub::Server::Request) }
    let(:logger)  { instance_double(Logger) }

    let(:stub_response) { instance_double(HttpStub::Server::Stub::Response::Base) }

    subject { request_pipeline.process(request, logger) }

    before(:example) { allow(stub_controller).to receive(:replay).and_return(stub_response) }

    context "when the stub controller replays a response" do

      before(:example) { allow(stub_response).to receive(:empty?).and_return(false) }

      it "returns the replayed response" do
        expect(subject).to eql(stub_response)
      end

    end

    context "when the stub controller does not replay a response" do

      let(:scenario_response) { double(HttpStub::Server::Stub::Response::Base, serve_on: nil) }

      before(:example) do
        allow(stub_response).to receive(:empty?).and_return(true)
        allow(scenario_controller).to receive(:activate).and_return(scenario_response)
      end

      context "but the scenario controller activates a scenario" do

        before(:each) { allow(scenario_response).to receive(:empty?).and_return(false) }

        it "returns the scenario response" do
          expect(subject).to eql(scenario_response)
        end

      end

      context "and the scenario controller does not activate a scenario" do

        let(:stub_match) { instance_double(HttpStub::Server::Stub::Match::Match) }

        before(:each) do
          allow(HttpStub::Server::Stub::Match::Match).to receive(:new).and_return(stub_match)
          allow(scenario_response).to receive(:empty?).and_return(true)
        end

        it "creates a match with no stub to indicate their was no match" do
          expect(HttpStub::Server::Stub::Match::Match).to receive(:new).with(nil, request)

          subject
        end

        it "registers the created match in the match registry" do
          expect(match_registry).to receive(:add).with(stub_match, logger)

          subject
        end

        it "returns a not found response" do
          expect(subject).to eql(HttpStub::Server::Response::NOT_FOUND)
        end

      end

    end

  end

end
