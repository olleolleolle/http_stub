describe HttpStub::Configurer::Request::StubPayloadBuilder do

  let(:builder) { HttpStub::Configurer::Request::StubPayloadBuilder.new }

  shared_context "add stub triggers" do

    let(:trigger_payloads) { (1..3).map { |i| { "trigger_#{i}_key" => "trigger #{i} value" } } }
    let(:trigger_builders) do
      trigger_payloads.map do |payload|
        instance_double(HttpStub::Configurer::Request::StubPayloadBuilder, build: payload)
      end
    end

    before(:example) { trigger_builders.each { |trigger_builder| builder.and_add_stub(trigger_builder) } }

  end

  describe "#build" do

    context "when provided a uri and stub arguments" do

      include_context "stub payload builder arguments"

      subject { builder.build }

      before(:example) do
        allow(HttpStub::Configurer::Request::ControllableValue).to receive(:format)

        builder.match_request(uri, request_options)
        builder.with_response(response_options)
      end

      context "when request header is provided" do

        it "formats the headers into control values" do
          expect(HttpStub::Configurer::Request::ControllableValue).to receive(:format).with(request_headers)

          subject
        end

      end

      context "when no request header is provided" do

        let(:request_headers) { nil }

        it "formats an empty header hash" do
          expect(HttpStub::Configurer::Request::ControllableValue).to receive(:format).with({})

          subject
        end

      end

      context "when a request parameter is provided" do

        it "formats the request parameters into control values" do
          expect(HttpStub::Configurer::Request::ControllableValue).to receive(:format).with(request_parameters)

          subject
        end

      end

      context "when no request parameter is provided" do

        let(:request_parameters) { nil }

        it "formats an empty parameter hash" do
          expect(HttpStub::Configurer::Request::ControllableValue).to receive(:format).with({})

          subject
        end

      end

      context "when stub triggers are added" do
        
        include_context "add stub triggers"

        it "builds the payload for each trigger" do
          trigger_builders.each { |trigger_builder| expect(trigger_builder).to receive(:build) }

          subject
        end

      end

      context "builds a request payload" do

        it "has an entry containing the control value representation of the uri" do
          allow(HttpStub::Configurer::Request::ControllableValue).to(
            receive(:format).with(uri).and_return("uri as a string")
          )

          expect(subject).to include(uri: "uri as a string")
        end

        it "has an entry for the method option" do
          expect(subject).to include(method: stub_method)
        end

        it "has an entry containing the string representation of the request headers" do
          allow(HttpStub::Configurer::Request::ControllableValue).to(
            receive(:format).with(request_headers).and_return("request headers as string")
          )

          expect(subject).to include(headers: "request headers as string")
        end

        it "has an entry containing the string representation of the request parameters" do
          allow(HttpStub::Configurer::Request::ControllableValue).to(
            receive(:format).with(request_parameters).and_return("request parameters as string")
          )

          expect(subject).to include(parameters: "request parameters as string")
        end

        context "when a status response argument is provided" do

          it "has a response entry for the argument" do
            expect(subject[:response]).to include(status: response_status)
          end

        end

        context "when no status response argument is provided" do

          let(:response_status) { nil }

          it "has a response entry with an empty status code" do
            expect(subject[:response]).to include(status: "")
          end

        end

        context "when response headers are provided" do

          let(:response_headers) { { response_header_name: "value" } }

          it "has a headers response entry containing the the provided headers" do
            expect(subject[:response]).to include(headers: response_headers)
          end

        end

        context "when response headers are omitted" do

          let (:response_headers) { nil }

          it "has a headers response entry containing an empty hash" do
            expect(subject[:response]).to include(headers: {})
          end

        end

        it "has an entry for the response body argument" do
          expect(subject[:response]).to include(body: response_body)
        end

        context "when a delay option is provided" do

          it "has a response entry for the argument" do
            expect(subject[:response]).to include(delay_in_seconds: response_delay_in_seconds)
          end

        end

        context "when a delay option is omitted" do

          let(:response_delay_in_seconds) { nil }

          it "has a response entry with an empty delay" do
            expect(subject[:response]).to include(delay_in_seconds: "")
          end

        end

        context "when stub triggers are added" do
          
          include_context "add stub triggers"

          it "has a triggers entry containing the stub trigger payloads" do
            expect(subject).to include(triggers: trigger_payloads)
          end

        end

        context "when no stub triggers are added" do

          it "has a triggers entry containing an empty hash" do
            expect(subject).to include(triggers: [])
          end

        end

      end

    end

  end

end
