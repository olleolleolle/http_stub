describe HttpStub::Configurer::DSL::StubBuilder do

  let(:response_defaults) { {} }

  let(:builder) { HttpStub::Configurer::DSL::StubBuilder.new(response_defaults) }

  shared_context "triggers one stub" do

    let(:trigger_stub) { instance_double(HttpStub::Configurer::Request::Stub) }
    let(:trigger_builder) do
      instance_double(HttpStub::Configurer::DSL::StubBuilder, build: trigger_stub)
    end

    before(:example) { builder.trigger(trigger_builder) }

  end

  shared_context "triggers many stubs" do

    let(:trigger_stubs) { (1..3).map { instance_double(HttpStub::Configurer::Request::Stub) } }
    let(:trigger_builders) do
      trigger_stubs.map { |stub| instance_double(HttpStub::Configurer::DSL::StubBuilder, build: stub) }
    end

    before(:example) { builder.trigger(trigger_builders) }

  end

  describe "#match_requests" do

    let(:fixture) { HttpStub::StubFixture.new }

    subject { builder.match_requests(fixture.request.uri, fixture.request.symbolized) }

    it "returns the builder to support method chaining" do
      expect(subject).to eql(builder)
    end

  end

  describe "#schema" do

    let(:type) { :some_type }

    subject { builder.schema(type, schema_definition) }

    context "when a definition is provided in a ruby hash" do

      let(:schema_definition) { { schema: "definition" } }

      it "returns a hash with a :schema entry containing both the type and schema definition" do
        expect(subject).to eql(schema: { type: type, definition: schema_definition })
      end

    end

  end

  describe "#respond_with" do

    subject { builder.respond_with(status: 201) }

    it "does not modify any provided response defaults" do
      original_response_defaults = response_defaults.clone

      subject

      expect(response_defaults).to eql(original_response_defaults)
    end

    it "returns the builder to support method chaining" do
      expect(subject).to eql(builder)
    end

  end

  describe "#trigger" do

    subject { builder.trigger(instance_double(HttpStub::Configurer::DSL::StubBuilder)) }

    it "returns the builder to support method chaining" do
      expect(subject).to eql(builder)
    end

  end

  describe "#invoke" do

    context "when the block accepts an argument" do

      subject { builder.invoke { |builder| builder.match_requests("/some_uri") } }

      it "invokes the block with the builder as the argument" do
        expect(builder).to receive(:match_requests).with("/some_uri")

        subject
      end

    end

    context "when the block accepts no arguments" do

      subject { builder.invoke { match_requests("/some_uri") } }

      it "invokes the block in the context of the builder" do
        expect(builder).to receive(:match_requests).with("/some_uri")

        subject
      end

    end

  end

  describe "#merge!" do

    subject { builder.merge!(provided_builder) }

    shared_context "a completely configured provided builder" do

      let(:provided_triggers) { (1..3).map { instance_double(HttpStub::Configurer::DSL::StubBuilder) } }

      let(:provided_builder) do
        HttpStub::Configurer::DSL::StubBuilder.new({}).tap do |builder|
          builder.match_requests("/replacement_uri", method: :put,
                                 headers:    { request_header_key: "replacement request header value",
                                               other_request_header_key: "other request header value" },
                                 parameters: { parameter_key: "replacement parameter value",
                                               other_request_parameter_key: "other request parameter value" })
          builder.respond_with(status: 203,
                               headers: { response_header_key: "reaplcement response header value",
                                          other_response_header_key: "other response header value" },
                               body: "replacement body value",
                               delay_in_seconds: 3)
          builder.trigger(provided_triggers)
        end
      end

    end

    context "when the builder has been completely configured" do

      let(:original_triggers) { (1..3).map { instance_double(HttpStub::Configurer::DSL::StubBuilder) } }

      before(:example) do
        builder.match_requests("/original_uri", method: :get,
                               headers:    { request_header_key: "original request header value" },
                               parameters: { parameter_key: "original parameter value" })
        builder.respond_with(status: 202,
                             headers: { response_header_key: "original response header value" },
                             body: "original body",
                             delay_in_seconds: 2)
        builder.trigger(original_triggers)
      end

      context "and a builder that is completely configured is provided" do

        include_context "a completely configured provided builder"

        it "replaces the uri" do
          subject

          expect(builder.request).to include(uri: "/replacement_uri")
        end

        it "replaces the request method" do
          subject

          expect(builder.request).to include(method: :put)
        end

        it "deeply merges the request headers" do
          subject

          expect(builder.request).to include(headers: { request_header_key: "replacement request header value",
                                                        other_request_header_key: "other request header value" })
        end

        it "deeply merges the request parameters" do
          subject

          expect(builder.request).to(
            include(parameters: { parameter_key: "replacement parameter value",
                                  other_request_parameter_key: "other request parameter value" })
          )
        end

        it "replaces the response status" do
          subject

          expect(builder.response).to include(status: 203)
        end

        it "deeply merges the response headers" do
          subject

          expect(builder.response).to include(headers: { response_header_key: "reaplcement response header value",
                                                         other_response_header_key: "other response header value" })
        end

        it "replaces the body" do
          subject

          expect(builder.response).to include(body: "replacement body value")
        end

        it "replaces the response delay" do
          subject

          expect(builder.response).to include(delay_in_seconds: 3)
        end

        it "adds to the triggers" do
          subject

          expect(builder.triggers).to eql(original_triggers + provided_triggers)
        end

      end

      context "and a builder that is empty is provided" do

        let(:provided_builder) { HttpStub::Configurer::DSL::StubBuilder.new({}) }

        it "preserves the uri" do
          subject

          expect(builder.request).to include(uri: "/original_uri")
        end

        it "preserves the request method" do
          subject

          expect(builder.request).to include(method: :get)
        end

        it "preserves the request headers" do
          subject

          expect(builder.request).to include(headers: { request_header_key: "original request header value" })
        end

        it "preserves the request parameters" do
          subject

          expect(builder.request).to include(parameters: { parameter_key: "original parameter value" })
        end

        it "preserves the response status" do
          subject

          expect(builder.response).to include(status: 202)
        end

        it "preserves the response headers" do
          subject

          expect(builder.response).to include(headers: { response_header_key: "original response header value" })
        end

        it "preserves the body" do
          subject

          expect(builder.response).to include(body: "original body")
        end

        it "preserves the response delay" do
          subject

          expect(builder.response).to include(delay_in_seconds: 2)
        end

        it "preserves the triggers" do
          subject

          expect(builder.triggers).to eql(original_triggers)
        end

      end

    end

    context "when the builder has not been previously configured" do

      include_context "a completely configured provided builder"

      it "assumes the provided uri" do
        subject

        expect(builder.request).to include(uri: "/replacement_uri")
      end

      it "assumes the provided request method" do
        subject

        expect(builder.request).to include(method: :put)
      end

      it "assumes the provided request headers" do
        subject

        expect(builder.request).to include(headers: { request_header_key: "replacement request header value",
                                                      other_request_header_key: "other request header value" })
      end

      it "assumes the provided request parameters" do
        subject

        expect(builder.request).to(
          include(parameters: { parameter_key: "replacement parameter value",
                                other_request_parameter_key: "other request parameter value" })
        )
      end

      it "assumes the provided response status" do
        subject

        expect(builder.response).to include(status: 203)
      end

      it "assumes the provided response headers" do
        subject

        expect(builder.response).to include(headers: { response_header_key: "reaplcement response header value",
                                                       other_response_header_key: "other response header value" })
      end

      it "assumes the provided response body" do
        subject

        expect(builder.response).to include(body: "replacement body value")
      end

      it "assumes the provided response delay" do
        subject

        expect(builder.response).to include(delay_in_seconds: 3)
      end

      it "assumes the provided triggers" do
        subject

        expect(builder.triggers).to eql(provided_triggers)
      end

    end

  end

  describe "#build" do

    let(:fixture) { HttpStub::StubFixture.new }
    let(:stub)    { instance_double(HttpStub::Configurer::Request::Stub) }

    subject do
      builder.match_requests(fixture.request.uri, fixture.request.symbolized)
      builder.respond_with(fixture.response.symbolized)

      builder.build
    end

    before(:example) { allow(HttpStub::Configurer::Request::Stub).to receive(:new).and_return(stub) }

    context "when provided a request match and response data" do

      it "creates a stub payload with request options that include the uri and the provided request options" do
        expect_stub_to_be_created_with(request: { uri: fixture.request.uri }.merge(fixture.request.symbolized))

        subject
      end

      it "creates a stub payload with response arguments" do
        expect_stub_to_be_created_with(response: fixture.response.symbolized)

        subject
      end

      context "when response default options are established" do

        let(:response_defaults) { { some_options: "default value" } }

        it "creates a stub payload with response arguments that includes the defaults" do
          expect_stub_to_be_created_with(response: fixture.response.symbolized.merge(response_defaults))

          subject
        end

        context "and response options provided match the defaults" do

          let(:response_defaults) do
            {
              status:           203,
              headers:          { "header-name-1" => "value 1", "header-name-2" => "value 2" },
              body:             "some body",
              delay_in_seconds: 8
            }
          end
          let(:response_overrides) do
            {
              status:  302,
              headers: { "header-name-2" => "updated value 2", "header-name-3" => "value 3" },
              body:    "another body"
            }
          end

          before(:example) { fixture.response = response_overrides }

          it "overriddes the defaults with the provided options" do
            expect_stub_to_be_created_with(
              response: {
                status:           302,
                headers:          { "header-name-1" => "value 1",
                                    "header-name-2" => "updated value 2",
                                    "header-name-3" => "value 3" },
                body:             "another body",
                delay_in_seconds: 8
              }
            )

            subject
          end

        end

      end

      context "when a trigger is added" do
        
        include_context "triggers one stub"

        it "creates a stub payload with the provided trigger builder" do
          expect_stub_to_be_created_with(triggers: [ trigger_builder ])

          subject
        end

      end

      context "when many triggers are added" do

        include_context "triggers many stubs"

        it "creates a stub payload with the provided trigger builders" do
          expect_stub_to_be_created_with(triggers: trigger_builders)

          subject
        end

      end

      it "returns the created stub" do
        expect(subject).to eql(stub)
      end

    end

    def expect_stub_to_be_created_with(args)
      expect(HttpStub::Configurer::Request::Stub).to receive(:new).with(hash_including(args))
    end

  end

end
