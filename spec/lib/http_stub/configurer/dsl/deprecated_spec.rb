describe HttpStub::Configurer::DSL::Deprecated do

  let(:stub_server) { double("StubServer") }

  shared_context "a method stubbing a response" do

    let(:stub_uri)   { "/some/stub/uri" }
    let(:method)     { :put }
    let(:headers)    { { header_key: "header value" } }
    let(:parameters) { { parameter_key: "parameter value" } }
    let(:response)   { { response_key: "response value" } }
    let(:options)    { { method: method, headers: headers, parameters: parameters, response: response } }

    before(:example) do
      allow(builder).to receive(:match_requests)
      allow(builder).to receive(:respond_with)
    end

    it "causes the builder being added to match requests on the provided uri" do
      expect(builder).to receive(:match_requests).with(hash_including(uri: stub_uri))

      subject
    end

    context "when a method is provided" do

      it "causes the builder being added to match requests on the provided method" do
        expect(builder).to receive(:match_requests).with(hash_including(method: method))

        subject
      end

    end

    context "when a method is omitted" do

      let(:options) { {} }

      it "causes the builder being added to not match requests based on method" do
        expect(builder).to receive(:match_requests).with(hash_excluding(:method))

        subject
      end

    end

    context "when parameters are provided" do

      it "causes the builder being added to match requests on the provided parameters" do
        expect(builder).to receive(:match_requests).with(hash_including(parameters: parameters))

        subject
      end

    end

    context "when parameters are omitted" do

      let(:options) { {} }

      it "causes the builder being added to not match requests based on parameters" do
        expect(builder).to receive(:match_requests).with(hash_excluding(:parameters))

        subject
      end

    end

    context "when headers are provided" do

      it "causes the builder being added to match requests on the provided headers" do
        expect(builder).to receive(:match_requests).with(hash_including(headers: headers))

        subject
      end

    end

    context "when headers are omitted" do

      let(:options) { {} }

      it "causes the builder being added to not match requests based on headers" do
        expect(builder).to receive(:match_requests).with(hash_excluding(:headers))

        subject
      end

    end

    it "adds the provided response data to the builder" do
      expect(builder).to receive(:respond_with).with(response)

      subject
    end

  end

  shared_examples_for "a deprecated DSL object" do

    [ :recall_stubs!, :clear_stubs! ].each do |stub_server_delegate_method|

      describe "##{stub_server_delegate_method}" do

        it "delegates to the stub server available to the dsl" do
          expect(stub_server).to receive(stub_server_delegate_method)

          dsl_object.send(stub_server_delegate_method)
        end

      end

    end

    describe "#server_has_started!" do

      it "informs the stub server that it has started" do
        expect(stub_server).to receive(:has_started!)

        dsl_object.server_has_started!
      end

    end

    describe "#activate!" do

      let(:activation_uri) { "/some/activation/uri" }

      it "delegates to the stub server available to the dsl" do
        expect(stub_server).to receive(:activate!).with(activation_uri)

        dsl_object.activate!(activation_uri)
      end

    end

    [ :stub!, :stub_response! ].each do |method|

      describe "##{method}" do

        include_context "a method stubbing a response"

        let(:builder) { instance_double(HttpStub::Configurer::DSL::StubBuilder) }

        subject { dsl_object.send(method, stub_uri, options) }

        before(:example) { allow(stub_server).to receive(:add_stub!).and_yield(builder) }

        it "adds a stub to the stub server" do
          expect(stub_server).to receive(:add_stub!)

          subject
        end

      end

    end

    describe "#stub_activator" do

      let(:activation_uri) { "/some/activation/uri" }

      include_context "a method stubbing a response"

      let(:builder) { instance_double(HttpStub::Configurer::DSL::StubActivatorBuilder) }

      subject { dsl_object.stub_activator(activation_uri, stub_uri, options) }

      before(:example) do
        allow(stub_server).to receive(:add_activator!).and_yield(builder)
        allow(builder).to receive(:on)
      end

      it "adds an activator to the stub server" do
        expect(stub_server).to receive(:add_activator!)

        subject
      end

      it "causes the builder being added to activate on the provided uri" do
        expect(builder).to receive(:on).with(activation_uri)

        subject
      end

    end

    describe "#clear_activators!" do

      it "informs the stub server to clear scenarios" do
        expect(stub_server).to receive(:clear_scenarios!)

        dsl_object.clear_activators!
      end

    end

  end

  context "when included in a class" do

    class HttpStub::Configurer::DSL::DeprecatedTest
      include HttpStub::Configurer::DSL::Deprecated

      class << self

        attr_accessor :stub_server

      end

      attr_accessor :stub_server

    end

    describe "the class in which the module was included" do

      let(:dsl_object) do
        HttpStub::Configurer::DSL::DeprecatedTest.stub_server = stub_server
        HttpStub::Configurer::DSL::DeprecatedTest
      end

      it_behaves_like "a deprecated DSL object"

    end

    describe "an instance of the class in which the module was included" do

      let(:dsl_object) do
        dsl_object = HttpStub::Configurer::DSL::DeprecatedTest.new
        dsl_object.stub_server = stub_server
        dsl_object
      end

      it_behaves_like "a deprecated DSL object"

    end

  end

end
