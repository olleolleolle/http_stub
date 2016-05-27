describe HttpStub::Server::Stub::Match::Rule::Method do

  let(:stub_method) { "put" }

  let(:the_method) { described_class.new(stub_method) }

  describe "#matches?" do

    let(:request_method) { "get" }
    let(:request)        { instance_double(HttpStub::Server::Request::Request, method: request_method) }
    let(:logger)         { instance_double(Logger) }

    subject { the_method.matches?(request, logger) }

    context "when the request method is identical to the stub method" do

      let(:request_method) { stub_method }

      it "returns true" do
        expect(subject).to be(true)
      end

    end

    context "when the stub method and request method are the the same value but have different casing" do

      let(:stub_method) { "GET" }

      it "returns true" do
        expect(subject).to be(true)
      end

    end

    context "when the stub method is omitted" do

      context "with a nil value" do

        let(:stub_method) { nil }

        it "returns true" do
          expect(subject).to be(true)
        end

      end

      context "with an empty string" do

        let(:stub_method) { "" }

        it "returns true" do
          expect(subject).to be(true)
        end

      end

    end

    context "when the stub method is different to the request method" do

      let(:stub_method)     { "delete" }
      let(:request_method)  { "get" }

      it "returns false" do
        expect(subject).to be(false)
      end

    end

  end

  describe "#to_s" do

    subject { the_method.to_s }

    context "when the stub method is not nil" do

      let(:stub_method) { "present" }

      it "returns the stub method" do
        expect(subject).to eql(stub_method)
      end

    end

    context "when the stub method is nil" do

      let(:stub_method) { nil }

      it "returns an empty string" do
        expect(subject).to eql("")
      end

    end

  end

end
