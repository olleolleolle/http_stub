describe HttpStub::Server::Stub::Match::Rule::Method do

  let(:raw_stub_method) { "put" }

  let(:the_method) { described_class.new(raw_stub_method) }

  describe "#matches?" do

    let(:request_method) { "get" }
    let(:request)        { instance_double(HttpStub::Server::Request, method: request_method) }
    let(:logger)         { instance_double(Logger) }

    subject { the_method.matches?(request, logger) }

    context "when the request method is identical to the stub method" do

      let(:request_method) { raw_stub_method }

      it "returns true" do
        expect(subject).to be(true)
      end

    end

    context "when the request method and stub method are the the same value but have different casing" do

      let(:raw_stub_method) { "GET" }

      it "returns true" do
        expect(subject).to be(true)
      end

    end

    context "when the stub method is omitted" do

      context "with a nil value" do

        let(:raw_stub_method) { nil }

        it "returns true" do
          expect(subject).to be(true)
        end

      end

      context "with an empty string" do

        let(:raw_stub_method) { "" }

        it "returns true" do
          expect(subject).to be(true)
        end

      end

    end

    context "when the request method is different to the stub method" do

      let(:request_method)  { "get" }
      let(:raw_stub_method) { "delete" }

      it "returns false" do
        expect(subject).to be(false)
      end

    end

  end

  describe "#to_s" do

    context "when the stub method provided is not nil" do

      let(:raw_stub_method) { "not_nil" }

      it "returns the stub method provided" do
        expect(the_method.to_s).to eql(raw_stub_method)
      end

    end

    context "when the stub method provided is nil" do

      let(:raw_stub_method) { nil }

      it "returns an empty string" do
        expect(the_method.to_s).to eql("")
      end

    end

  end

end
