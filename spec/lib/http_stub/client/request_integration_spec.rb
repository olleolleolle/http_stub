describe HttpStub::Client::Request, "integrating with a server" do

  let(:request_intent)         { "some request intent" }
  let(:request_args_overrides) { {} }
  let(:request_args)            do
    {
      method:       :post,
      base_uri:     server_uri,
      path:         "stubs/reset",
      intent:       request_intent,
      http_options: { open_timeout: 1 }
    }.merge(request_args_overrides)
  end

  let(:request) { described_class.new(request_args) }

  describe "#submit" do

    subject { request.submit }

    context "when a server is running" do
      include_context "server integration"

      context "and a valid request is submitted" do

        it "executes without error" do
          expect { subject }.not_to raise_error
        end

        it "returns a response that indicates the request was issued" do
          expect(subject.code).to eql("200")
        end

        context "that contains parameters" do

          let(:request_args_overrides) do
            {
              path:       "scenarios/activate",
              parameters: { "names[]" => [ "invalid_scenario" ] }
            }
          end

          it "executes without error" do
            expect { subject }.not_to raise_error
          end

          it "returns a response that indicates the request honoured the parameters" do
            expect(subject.body).to include("invalid_scenario")
          end

        end

      end

    end

    context "when a request is submitted to an unavailable server" do

      let(:request_args_overrides) do
        {
          base_uri: "http://localhost:#{HttpStub::Port.free_port}",
          path:     "does/not/exist"
        }
      end

      it "raises an exception" do
        expect { subject }.to raise_error(StandardError)
      end

    end

  end

end
