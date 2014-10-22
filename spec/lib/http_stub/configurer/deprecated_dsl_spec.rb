describe HttpStub::Configurer::DeprecatedDSL do

  let(:stub_server) { double("StubServer") }

  shared_context "a method stubbing a response" do

    let(:stub_uri)   { "/some/stub/uri" }
    let(:method)     { :put }
    let(:headers)    { { header_key: "header value" } }
    let(:parameters) { { parameter_key: "parameter value" } }
    let(:response)   { { response_key: "response value" } }
    let(:options)    { { method: method, headers: headers, parameters: parameters, response: response } }

    before(:example) do
      allow(builder).to receive(:match_request)
      allow(builder).to receive(:respond_with)
    end

    it "causes the builder being added to match on the provided uri" do
      expect(builder).to receive(:match_request).with(stub_uri, anything)

      subject
    end

    context "when a method is provided" do

      it "causes the builder being added to match on the provided method" do
        expect(builder).to receive(:match_request).with(anything, hash_including(method: method))

        subject
      end

    end

    context "when a method is omitted" do

      let(:options) { {} }

      it "causes the builder being added to not match on method" do
        expect(builder).to receive(:match_request).with(anything, hash_excluding(:method))

        subject
      end

    end

    context "when parameters are provided" do

      it "causes the builder being added to match on the provided parameters" do
        expect(builder).to receive(:match_request).with(anything, hash_including(parameters: parameters))

        subject
      end

    end

    context "when parameters are omitted" do

      let(:options) { {} }

      it "causes the builder being added to not match on parameters" do
        expect(builder).to receive(:match_request).with(anything, hash_excluding(:parameters))

        subject
      end

    end

    context "when headers are provided" do

      it "causes the builder being added to match on the provided headers" do
        expect(builder).to receive(:match_request).with(anything, hash_including(headers: headers))

        subject
      end

    end

    context "when headers are omitted" do

      let(:options) { {} }

      it "causes the builder being added to not match on headers" do
        expect(builder).to receive(:match_request).with(anything, hash_excluding(:headers))

        subject
      end

    end

    it "adds the provided response data to the builder" do
      expect(builder).to receive(:respond_with).with(response)

      subject
    end

  end

  shared_examples_for "a deprecated DSL object" do

    [ :recall_stubs!, :clear_stubs!, :clear_activators! ].each do |stub_server_delegate_method|

      describe "##{stub_server_delegate_method}" do

        it "delegates to the stub server available to the dsl" do
          expect(stub_server).to receive(stub_server_delegate_method)

          dsl_object.send(stub_server_delegate_method)
        end

      end

    end

    describe "#server_has_started!" do

      let(:activation_uri) { "http://some/activation/uri" }

      it "informs the stub server that it has started" do
        expect(stub_server).to receive(:has_started!)

        dsl_object.server_has_started!
      end

    end

    describe "#activate!" do

      let(:activation_uri) { "http://some/activation/uri" }

      it "delegates to the stub server available to the dsl" do
        expect(stub_server).to receive(:activate!).with(activation_uri)

        dsl_object.activate!(activation_uri)
      end

    end

    [ :stub!, :stub_response! ].each do |method|

      describe "##{method}" do

        include_context "a method stubbing a response"

        let(:builder) { instance_double(HttpStub::Configurer::Request::StubPayloadBuilder) }

        subject { dsl_object.send(method, stub_uri, options) }

        before(:example) { allow(stub_server).to receive(:add_stub!).and_yield(builder) }

        it "adds a stub to the stub server" do
          expect(stub_server).to receive(:add_stub!)

          subject
        end

      end

    end

    describe "#stub_activator" do

      let(:activation_uri) { "http://some/activator/uri" }

      include_context "a method stubbing a response"

      let(:builder) { instance_double(HttpStub::Configurer::Request::StubActivatorPayloadBuilder) }

      subject { dsl_object.stub_activator(activation_uri, stub_uri, options) }

      before(:example) do
        allow(stub_server).to receive(:add_activator!).and_yield(builder)
        allow(builder).to receive(:path)
      end

      it "adds an activator to the stub server" do
        expect(stub_server).to receive(:add_activator!)

        subject
      end

      it "causes the builder being added to activate on the provided uri" do
        expect(builder).to receive(:path).with(activation_uri)

        subject
      end

    end

  end

  context "when included in a class" do

    class HttpStub::Configurer::DeprecatedDSLTest
      include HttpStub::Configurer::DeprecatedDSL

      class << self

        attr_accessor :stub_server

      end

      attr_accessor :stub_server

    end

    describe "the class in which the module was included" do

      let(:dsl_object) do
        HttpStub::Configurer::DeprecatedDSLTest.stub_server = stub_server
        HttpStub::Configurer::DeprecatedDSLTest
      end

      it_behaves_like "a deprecated DSL object"

    end

    describe "an instance of the class in which the module was included" do

      let(:dsl_object) do
        dsl_object = HttpStub::Configurer::DeprecatedDSLTest.new
        dsl_object.stub_server = stub_server
        dsl_object
      end

      it_behaves_like "a deprecated DSL object"

    end

  end

end
