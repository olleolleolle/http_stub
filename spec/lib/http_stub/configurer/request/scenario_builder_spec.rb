describe HttpStub::Configurer::Request::ScenarioBuilder do

  let(:stub_fixture) { HttpStub::StubFixture.new }

  let(:response_defaults) { { some_default_key: "some default value" } }
  let(:activation_uri)    { "some/activation/uri" }

  let(:scenario_builder) { HttpStub::Configurer::Request::ScenarioBuilder.new(response_defaults, activation_uri) }

  it "produces stub builders" do
    expect(scenario_builder).to be_a(HttpStub::Configurer::Request::StubBuilderProducer)
  end

  describe "#add_stub!" do

    let(:stub_builder) { instance_double(HttpStub::Configurer::Request::StubBuilder) }

    context "when a block is provided" do

      let(:block) { lambda { |_builder| "some block" } }

      subject { scenario_builder.add_stub!(&block) }

      before(:example) { allow(HttpStub::Configurer::Request::StubBuilder).to receive(:new).and_return(stub_builder) }

      it "creates a stub builder with the response defaults provided to the scenario builder" do
        expect(HttpStub::Configurer::Request::StubBuilder).to receive(:new).and_return(stub_builder)

        subject
      end

      it "yields the stub builder to the provided block" do
        expect(block).to receive(:call).with(stub_builder)

        subject
      end

      it "results in the stub being built when the scenario is built" do
        subject
        expect(stub_builder).to receive(:build)

        scenario_builder.build
      end

    end

    context "when a builder is provided" do

      subject { scenario_builder.add_stub!(stub_builder) }

      it "results in the stub being built when the scenario is built" do
        subject
        expect(stub_builder).to receive(:build)

        scenario_builder.build
      end

    end

  end

  describe "#build" do

    let(:scenario) { instance_double(HttpStub::Configurer::Request::Scenario) }

    subject { scenario_builder.build }

    before(:example) { allow(HttpStub::Configurer::Request::Scenario).to receive(:new).and_return(scenario) }

    it "creates a scenario that includes the uri" do
      expect(HttpStub::Configurer::Request::Scenario).to(
        receive(:new).with(hash_including(activation_uri: activation_uri))
      )

      subject
    end

    context "when multiple stubs have been added" do

      let(:stubs) { (1..3).map { instance_double(HttpStub::Configurer::Request::Stub) } }
      let(:stub_builders) do
        stubs.map { |stub| instance_double(HttpStub::Configurer::Request::StubBuilder, build: stub) }
      end

      before(:example) do
        allow(HttpStub::Configurer::Request::StubBuilder).to receive(:new).and_return(*stub_builders)
        stub_builders.each { scenario_builder.add_stub! { |_builder| "some block" } }
      end

      it "builds the stubs" do
        stub_builders.each { |stub_builder| expect(stub_builder).to receive(:build) }

        subject
      end

      it "creates a scenario that includes the built stubs" do
        expect(HttpStub::Configurer::Request::Scenario).to receive(:new).with(hash_including(stubs: stubs))

        subject
      end

    end

    context "when one stub has been added" do

      let(:stub)         { instance_double(HttpStub::Configurer::Request::Stub) }
      let(:stub_builder) { instance_double(HttpStub::Configurer::Request::StubBuilder, build: stub) }

      before(:example) do
        allow(HttpStub::Configurer::Request::StubBuilder).to receive(:new).and_return(stub_builder)
        scenario_builder.add_stub! { |_builder| "some block" }
      end

      it "builds the stub" do
        expect(stub_builder).to receive(:build)

        subject
      end

      it "creates a scenario that includes the built stub" do
        expect(HttpStub::Configurer::Request::Scenario).to receive(:new).with(hash_including(stubs: [ stub ]))

        subject
      end

    end

  end

end
