describe HttpStub::Configurator::Stub::Stub do

  let(:parent_stub) { nil }

  let(:composed_stub) { described_class.new(parent_stub) }

  let(:composed_stub_match_rules_payload) { composed_stub.to_hash[:match_rules] }
  let(:composed_stub_response_payload)    { composed_stub.to_hash[:response] }
  let(:composed_stub_triggers_payload)    { composed_stub.to_hash[:triggers] }

  shared_context "triggers one scenario" do

    let(:trigger_scenario) { "Some triggered scenario" }

    before(:example) { composed_stub.trigger(scenario: trigger_scenario) }

  end

  shared_context "triggers many scenarios" do

    let(:trigger_scenarios) { (1..3).map { |i| "Some triggered scenario #{i}" } }

    before(:example) { composed_stub.trigger(scenarios: trigger_scenarios) }

  end

  shared_context "triggers one stub" do

    let(:trigger_stub_hash) { { trigger_key: "trigger value" } }
    let(:trigger_stub)      { instance_double(described_class, to_hash: trigger_stub_hash) }

    before(:example) { composed_stub.trigger(stub: trigger_stub) }

  end

  shared_context "triggers many stubs" do

    let(:trigger_stub_hashes) { (1..3).map { |i| { trigger_key: "trigger value #{i}" } } }
    let(:trigger_stubs)       { trigger_stub_hashes.map { |hash| instance_double(described_class, to_hash: hash) } }

    before(:example) { composed_stub.trigger(stubs: trigger_stubs) }

  end

  describe "constructor" do

    class HttpStub::Configurator::Stub::StubWithObservedMerge < HttpStub::Configurator::Stub::Stub

      attr_reader :merged_stubs

      def initialize(parent=nil, &block)
        @merged_stubs = []
        super(parent, &block)
      end

      def merge!(stub)
        @merged_stubs << stub
      end

    end

    context "when a parent stub is provided" do

      let(:parent_stub) { instance_double(described_class) }

      let(:composed_stub) { HttpStub::Configurator::Stub::StubWithObservedMerge.new(parent_stub) }

      it "merges the parent stub" do
        composed_stub

        expect(composed_stub.merged_stubs).to eql([ parent_stub ])
      end

    end

    context "when a block is provided" do

      let(:block_verifier) { double("BlockVerifier", verify: nil) }
      let(:block)          { lambda { |builder| block_verifier.verify(builder) } }

      let(:composed_stub) { HttpStub::Configurator::Stub::StubWithObservedMerge.new(&block) }

      it "creates a stub that is yielded to the provided block" do
        expect(block_verifier).to receive(:verify).with(a_kind_of(described_class))

        composed_stub
      end

      it "does not merge any parent stubs" do
        composed_stub

        expect(composed_stub.merged_stubs).to eql([])
      end

    end

    context "when neither a parent stub or block is provided" do

      let(:composed_stub) { HttpStub::Configurator::Stub::StubWithObservedMerge.new(nil) }

      it "does not merge any parent stub" do
        composed_stub

        expect(composed_stub.merged_stubs).to eql([])
      end

    end

  end

  describe "#match_requests" do

    let(:fixture) { HttpStub::Configurator::StubBuilder.new }

    subject { composed_stub.match_requests(fixture.match_rules) }

    it "returns the stub to support method chaining" do
      expect(subject).to eql(composed_stub)
    end

  end

  describe "#schema" do

    let(:type) { :some_type }

    subject { composed_stub.schema(type, schema_definition) }

    context "when a definition is provided in a ruby hash" do

      let(:schema_definition) { { schema: "definition" } }

      it "returns a hash with a :schema entry containing both the type and schema definition" do
        expect(subject).to eql(schema: { type: type, definition: schema_definition })
      end

    end

  end

  describe "#respond_with" do

    context "when a block is provided referencing the matching request" do

      let(:response_block) { lambda { |request| { headers: request.headers[:some_header] } } }

      subject { composed_stub.respond_with(&response_block) }

      it "adds the block to the stub payloads response" do
        subject

        expect(composed_stub_response_payload).to include(blocks: [ response_block ])
      end

      it "returns the stub to support method chaining" do
        expect(subject).to eql(composed_stub)
      end

    end

    context "when a hash is provided" do

      let(:response_hash) { { status: 201 } }

      subject { composed_stub.respond_with(response_hash) }

      it "includes the proivded hash in the stub payloads response" do
        subject

        expect(composed_stub_response_payload).to include(response_hash)
      end

      it "returns the stub to support method chaining" do
        expect(subject).to eql(composed_stub)
      end

    end

  end

  describe "#trigger" do

    let(:args) { {} }

    subject { composed_stub.trigger(args) }

    it "returns the stub to support method chaining" do
      expect(subject).to eql(composed_stub)
    end

    context "when scenarios are provided" do

      let(:scenarios) { (1..3).map { |i| "Scenario name #{i}" } }

      let(:args) { { scenarios: scenarios } }

      it "adds the scenarios" do
        subject

        expect(composed_stub_triggers_payload).to include(scenario_names: scenarios)
      end

    end

    context "when a scenario is provided" do

      let(:scenario) { "Some scenario name" }

      let(:args) { { scenario: scenario } }

      it "adds the scenario" do
        subject

        expect(composed_stub_triggers_payload).to include(scenario_names: [ scenario ])
      end

    end

    context "when stubs are provided" do

      let(:stub_hashes) { (1..3).map { |i| { stub_key: "stub value #{i}" } } }
      let(:stubs)       { stub_hashes.map { |hash| instance_double(described_class, to_hash: hash) } }

      let(:args) { { stubs: stubs } }

      it "adds the stubs" do
        subject

        expect(composed_stub_triggers_payload).to include(stubs: stub_hashes)
      end

    end

    context "when a stub is provided" do

      let(:stub_hash) { { stub_key: "stub value" } }
      let(:stub)      { instance_double(described_class, to_hash: stub_hash) }

      let(:args) { { stub: stub } }

      it "adds the stub" do
        subject

        expect(composed_stub_triggers_payload).to include(stubs: [ stub_hash ])
      end

    end

  end

  describe "#invoke" do

    context "when the block accepts an argument" do

      subject { composed_stub.invoke { |a_stub| a_stub.match_requests(uri: "/some_uri") } }

      it "invokes the block with the stub as the argument" do
        expect(composed_stub).to receive(:match_requests).with(uri: "/some_uri")

        subject
      end

    end

    context "when the block accepts no arguments" do

      subject { composed_stub.invoke { match_requests(uri: "/some_uri") } }

      it "invokes the block in the context of the stub" do
        expect(composed_stub).to receive(:match_requests).with(uri: "/some_uri")

        subject
      end

    end

  end

  describe "#merge!" do

    subject { composed_stub.merge!(provided_stub) }

    shared_context "a completely configured provided stub" do

      let(:provided_trigger_scenarios)   { (1..3).map { |i| "Triggered scenario #{i}" } }
      let(:provided_trigger_stub_hashes) { (1..3).map { |i| { trigger_hash_key: "trigger hash value #{i}" } } }
      let(:provided_trigger_stubs)       do
        provided_trigger_stub_hashes.map { |hash| instance_double(described_class, to_hash: hash) }
      end

      let(:provided_stub) do
        described_class.new.tap do |a_stub|
          a_stub.match_requests(uri:        "/replacement_uri",
                                method:     :put,
                                headers:    { request_header_key: "replacement request header value",
                                              other_request_header_key: "other request header value" },
                                parameters: { parameter_key: "replacement parameter value",
                                              other_request_parameter_key: "other request parameter value" })
          a_stub.respond_with(status:           203,
                              headers:          { response_header_key: "replacement response header value",
                                                  other_response_header_key: "other response header value" },
                              body:             "replacement body value",
                              delay_in_seconds: 3)
          a_stub.trigger(scenarios: provided_trigger_scenarios,
                         stubs:     provided_trigger_stubs)
        end
      end

    end

    context "when the stub has been completely configured" do

      let(:original_trigger_scenarios)   { (1..3).map { |i| "Original trigger scenario #{i}" } }
      let(:original_trigger_stub_hashes) { (1..3).map { |i| { match_rules: { uri: "original/uri/#{i}" } } } }
      let(:original_trigger_stubs)       do
        original_trigger_stub_hashes.map { |hash| instance_double(described_class, to_hash: hash) }
      end

      before(:example) do
        composed_stub.match_requests(uri:        "/original_uri",
                                     method:     :get,
                                     headers:    { request_header_key: "original request header value" },
                                     parameters: { parameter_key: "original parameter value" })
        composed_stub.respond_with(status:           202,
                                   headers:          { response_header_key: "original response header value" },
                                   body:             "original body",
                                   delay_in_seconds: 2)
        composed_stub.trigger(scenarios: original_trigger_scenarios,
                              stubs:     original_trigger_stubs)
      end

      context "and a stub that is completely configured is provided" do
        include_context "a completely configured provided stub"

        it "replaces the matched uri" do
          subject

          expect(composed_stub_match_rules_payload).to include(uri: "/replacement_uri")
        end

        it "replaces the matched method" do
          subject

          expect(composed_stub_match_rules_payload).to include(method: :put)
        end

        it "deeply merges the matched headers" do
          subject

          expect(composed_stub_match_rules_payload).to(
            include(headers: { request_header_key:       "replacement request header value",
                               other_request_header_key: "other request header value" })
          )
        end

        it "deeply merges the matched parameters" do
          subject

          expect(composed_stub_match_rules_payload).to(
            include(parameters: { parameter_key: "replacement parameter value",
                                  other_request_parameter_key: "other request parameter value" })
          )
        end

        it "replaces the response status" do
          subject

          expect(composed_stub_response_payload).to include(status: 203)
        end

        it "deeply merges the response headers" do
          subject

          expect(composed_stub_response_payload).to(
            include(headers: { response_header_key: "replacement response header value",
                               other_response_header_key: "other response header value" })
          )
        end

        it "replaces the response body" do
          subject

          expect(composed_stub_response_payload).to include(body: "replacement body value")
        end

        it "replaces the response delay" do
          subject

          expect(composed_stub_response_payload).to include(delay_in_seconds: 3)
        end

        it "adds to the triggered scenarios" do
          subject

          expect(composed_stub_triggers_payload).to(
            include(scenario_names: original_trigger_scenarios + provided_trigger_scenarios)
          )
        end

        it "adds to the triggered stubs" do
          subject

          expect(composed_stub_triggers_payload).to(
            include(stubs: original_trigger_stub_hashes + provided_trigger_stub_hashes)
          )
        end

      end

      context "and a stub that is empty is provided" do

        let(:provided_stub) { described_class.new }

        it "preserves the matched uri" do
          subject

          expect(composed_stub_match_rules_payload).to include(uri: "/original_uri")
        end

        it "preserves the matched method" do
          subject

          expect(composed_stub_match_rules_payload).to include(method: :get)
        end

        it "preserves the matched headers" do
          subject

          expect(composed_stub_match_rules_payload).to(
            include(headers: { request_header_key: "original request header value" })
          )
        end

        it "preserves the matched parameters" do
          subject

          expect(composed_stub_match_rules_payload).to(
            include(parameters: { parameter_key: "original parameter value" })
          )
        end

        it "preserves the response status" do
          subject

          expect(composed_stub_response_payload).to include(status: 202)
        end

        it "preserves the response headers" do
          subject

          expect(composed_stub_response_payload).to(
            include(headers: { response_header_key: "original response header value" })
          )
        end

        it "preserves the response body" do
          subject

          expect(composed_stub_response_payload).to include(body: "original body")
        end

        it "preserves the response delay" do
          subject

          expect(composed_stub_response_payload).to include(delay_in_seconds: 2)
        end

        it "preserves the triggered scenarios" do
          subject

          expect(composed_stub_triggers_payload).to include(scenario_names: original_trigger_scenarios)
        end

        it "preserves the triggered stubs" do
          subject

          expect(composed_stub_triggers_payload).to include(stubs: original_trigger_stub_hashes)
        end

      end

    end

    context "when the stub has not been previously configured" do
      include_context "a completely configured provided stub"

      it "assumes the provided matched uri" do
        subject

        expect(composed_stub_match_rules_payload).to include(uri: "/replacement_uri")
      end

      it "assumes the provided matched method" do
        subject

        expect(composed_stub_match_rules_payload).to include(method: :put)
      end

      it "assumes the provided matched headers" do
        subject

        expect(composed_stub_match_rules_payload).to(
          include(headers: { request_header_key:       "replacement request header value",
                             other_request_header_key: "other request header value" })
        )
      end

      it "assumes the provided matched parameters" do
        subject

        expect(composed_stub_match_rules_payload).to(
          include(parameters: { parameter_key: "replacement parameter value",
                                other_request_parameter_key: "other request parameter value" })
        )
      end

      it "assumes the provided response status" do
        subject

        expect(composed_stub_response_payload).to include(status: 203)
      end

      it "assumes the provided response headers" do
        subject

        expect(composed_stub_response_payload).to(
          include(headers: { response_header_key:       "replacement response header value",
                             other_response_header_key: "other response header value" })
        )
      end

      it "assumes the provided response body" do
        subject

        expect(composed_stub_response_payload).to include(body: "replacement body value")
      end

      it "assumes the provided response delay" do
        subject

        expect(composed_stub_response_payload).to include(delay_in_seconds: 3)
      end

      it "assumes the provided triggered scenarios" do
        subject

        expect(composed_stub_triggers_payload).to include(scenario_names: provided_trigger_scenarios)
      end

      it "assumes the provided triggered stubs" do
        subject

        expect(composed_stub_triggers_payload).to include(stubs: provided_trigger_stub_hashes)
      end

    end

  end

  describe "#id" do

    let(:fixture) { HttpStub::Configurator::StubBuilder.new }

    subject { composed_stub.id }

    before(:example) do
      fixture.with_response_block!
      fixture.with_triggered_scenarios!
    end

    context "when a stub has been supplied data" do

      before(:example) do
        composed_stub.match_requests(fixture.match_rules)
        composed_stub.respond_with(fixture.response)
      end

      it "returns a string identifying the stub" do
        expect(composed_stub.id).to be_a(String)
      end

      context "when the stubs data has not changed" do

        it "always returns an equal value" do
          expect(subject).to eql(composed_stub.id)
        end

      end

      context "when the stubs data has changed" do

        before(:example) do
          @initial_id = composed_stub.id

          composed_stub.match_requests(uri: "some_other_uri")
        end

        it "returns a different value" do
          expect(subject).to_not eql(@initial_id)
        end

      end

      context "when compared with that of another stub" do

        let(:other_composed_stub) { described_class.new(parent_stub) }

        before(:example) do
          other_composed_stub.match_requests(fixture.match_rules)
          other_composed_stub.respond_with(fixture.response)
        end

        context "who has the same data" do

          it "returns the same value" do
            expect(subject).to eql(other_composed_stub.id)
          end

        end

        context "who has different data" do

          before(:example) { other_composed_stub.trigger(fixture.triggers) }

          it "returns a different value" do
            expect(subject).to_not eql(other_composed_stub.id)
          end

        end

      end

    end

    context "when a stub has not been supplied data" do

      it "always returns an equal value" do
        expect(subject).to eql(composed_stub.id)
      end

    end

  end

  describe "#to_hash" do

    let(:fixture)  { HttpStub::Configurator::StubBuilder.new }
    let(:triggers) { { scenarios: [], stubs: [] } }

    subject do
      composed_stub.match_requests(fixture.match_rules.to_hash)
      composed_stub.respond_with(fixture.response.to_hash)
      composed_stub.trigger(triggers)

      composed_stub.to_hash
    end

    it "returns a hash with indifferent access" do
      expect(subject).to be_a(HashWithIndifferentAccess)
    end

    context "when provided with request match and response data" do

      it "creates a hash with match rules that include the uri and the match options" do
        expect(subject[:match_rules]).to eql(fixture.match_rules.to_hash)
      end

      it "creates a hash with response arguments" do
        expect(subject[:response]).to eql(fixture.response.to_hash)
      end

      context "and the response data contains blocks" do

        before(:example) { fixture.with_response_block! }

        it "creates a hash with response arguments that include the blocks" do
          expect(subject[:response]).to include(blocks: fixture.response.blocks)
        end

      end

      describe "creates a hash with triggers that" do

        context "when a scenario trigger is added" do
          include_context "triggers one scenario"

          it "contain the provided trigger scenario name" do
            expect(subject[:triggers]).to include(scenario_names: [ trigger_scenario ])

            subject
          end

        end

        context "when many scenario triggers are added" do
          include_context "triggers many scenarios"

          it "contain the provided trigger scenario names" do
            expect(subject[:triggers]).to include(scenario_names: trigger_scenarios)

            subject
          end

        end

        context "when a stub trigger is added" do
          include_context "triggers one stub"

          it "contain the provided triggerred stub hash" do
            expect(subject[:triggers]).to include(stubs: [ trigger_stub_hash ])

            subject
          end

        end

        context "when many stub triggers are added" do
          include_context "triggers many stubs"

          it "contains the provided triggerred stub hashes" do
            expect(subject[:triggers]).to include(stubs: trigger_stub_hashes)

            subject
          end

        end

      end

      context "when a stub is provided that contains defaults" do

        let(:match_rule_defaults) do
          {
            uri:        "/uri/value",
            headers:    { "request_header_name_1" => "request header value 1",
                          "request_header_name_2" => "request header value 2" },
            parameters: { "parameter_name_1" => "parameter value 1",
                          "parameter_name_2" => "parameter value 2" },
            body:       "body value"
          }
        end
        let(:response_block_default) do
          lambda do
            { status: 301 }
          end
        end
        let(:response_defaults) do
          {
            status:           203,
            headers:          { "response_header_name_1" => "response header value 1",
                                "response_header_name_2" => "response header value 2" },
            body:             "some body",
            delay_in_seconds: 8,
            blocks:           [ response_block_default ]
          }
        end
        let(:trigger_scenario_defaults)  { (1..3).map { |i| "Default trigger scenario #{i}" } }
        let(:trigger_stub_hash_defaults) { (1..3).map { |i| { match_request: { uri: "Default stub uri #{i}" } } } }

        let(:parent_hash) do
          {
            match_rules: match_rule_defaults,
            response:    response_defaults,
            triggers:    { scenario_names: trigger_scenario_defaults,
                           stubs:          trigger_stub_hash_defaults }
          }
        end
        let(:parent_stub) { instance_double(described_class, to_hash: parent_hash) }

        describe "the match rules payload" do

          let(:match_rule_overrides) do
            {
              uri:        "/some/updated/uri",
              headers:    { "request_header_name_2" => "updated request header value 2",
                            "request_header_name_3" => "request header value 3" },
              parameters: { "parameter_name_2" => "updated parameter value 2",
                            "parameter_name_3" => "parameter value 3" },
              body:       "updated body value"
            }
          end

          before(:example) { fixture.match_rules = match_rule_overrides }

          it "merges any defaults with values established in the stub" do
            expect(subject[:match_rules]).to eql(
              {
                uri:              "/some/updated/uri",
                headers:          { "request_header_name_1" => "request header value 1",
                                    "request_header_name_2" => "updated request header value 2",
                                    "request_header_name_3" => "request header value 3" },
                parameters:       { "parameter_name_1" => "parameter value 1",
                                    "parameter_name_2" => "updated parameter value 2",
                                    "parameter_name_3" => "parameter value 3" },
                body:             "updated body value"
              }.with_indifferent_access
            )
          end

        end

        describe "the response payload" do

          let(:response_block_override) do
            lambda do
              { status: 400 }
            end
          end
          let(:response_overrides) do
            {
              status:  302,
              headers: { "response_header_name_2" => "updated response header value 2",
                         "response_header_name_3" => "response header value 3" },
              body:    "updated body",
              blocks:  [ response_block_override ]
            }
          end

          before(:example) { fixture.response = response_overrides }

          it "merges any defaults with values established in the stub" do
            expect(subject[:response]).to eql(
              {
                status:           302,
                headers:          { "response_header_name_1" => "response header value 1",
                                    "response_header_name_2" => "updated response header value 2",
                                    "response_header_name_3" => "response header value 3" },
                body:             "updated body",
                delay_in_seconds: 8,
                blocks:           [ response_block_default, response_block_override ]
              }.with_indifferent_access
            )
          end

        end

        describe "the triggers payload" do

          let(:trigger_scenarios)   { (1..3).map { |i| "Trigger scenario #{i}" } }
          let(:trigger_stub_hashes) { (1..3).map { |i| { trigger_key: "trigger #{i}" } } }
          let(:trigger_stubs)       do
            trigger_stub_hashes.map { |hash| instance_double(described_class, to_hash: hash) }
          end

          let(:triggers) { { scenarios: trigger_scenarios, stubs: trigger_stubs } }

          it "combines any scenario defaults with values established in the stub" do
            expect(subject[:triggers]).to include(scenario_names: trigger_scenario_defaults + trigger_scenarios)

            subject
          end

          it "combines any stub defaults with values established in the stub" do
            expect(subject[:triggers]).to include(stubs: trigger_stub_hash_defaults + trigger_stub_hashes)

            subject
          end

        end

      end

    end

  end

end
