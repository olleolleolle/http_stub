describe HttpStub::Configurer::Request::StubBuilder do

  let(:response_defaults) { {} }

  let(:builder) { HttpStub::Configurer::Request::StubBuilder.new(response_defaults) }

  shared_context "triggers one stub" do

    let(:trigger_stub) { instance_double(HttpStub::Configurer::Request::Stub) }
    let(:trigger_builder) do
      instance_double(HttpStub::Configurer::Request::StubBuilder, build: trigger_stub)
    end

    before(:example) { builder.trigger(trigger_builder) }

  end

  shared_context "triggers many stubs" do

    let(:trigger_stubs) { (1..3).map { instance_double(HttpStub::Configurer::Request::Stub) } }
    let(:trigger_builders) do
      trigger_stubs.map { |stub| instance_double(HttpStub::Configurer::Request::StubBuilder, build: stub) }
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

    subject { builder.trigger(instance_double(HttpStub::Configurer::Request::StubBuilder)) }

    it "returns the builder to support method chaining" do
      expect(subject).to eql(builder)
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
