describe HttpStub::Server::Stub::Response::Attribute::Body do

  let(:body) { described_class.new(stub_body) }

  describe "#with_values_from" do

    let(:request) { HttpStub::Server::Request::Request }

    subject { body.with_values_from(request) }

    context "when a body is provided" do

      let(:stub_body) { "some stub body" }

      it "interpolates the stub body with values from the request" do
        expect(HttpStub::Server::Stub::Response::Attribute::Interpolator).to(
          receive(:interpolate).with(stub_body, request)
        )

        subject
      end

      it "returns the interpolation result" do
        interpolated_body = "some interpolated body"
        allow(HttpStub::Server::Stub::Response::Attribute::Interpolator).to(
          receive(:interpolate).and_return(interpolated_body)
        )

        expect(subject).to eql(interpolated_body)
      end

    end

    context "when the body is nil" do

      let(:stub_body) { nil }

      it "returns nil" do
        expect(subject).to eql(nil)
      end

    end

  end

  describe "#provided?" do

    subject { body.provided? }

    context "when the provided body is not nil" do

      let(:stub_body) { "" }

      it "returns true" do
        expect(subject).to eql(true)
      end

    end

    context "when the provided body is nil" do

      let(:stub_body) { nil }

      it "returns false" do
        expect(subject).to eql(false)
      end

    end

  end

  describe "#to_s" do

    subject { body.to_s }

    context "when a body is provided" do

      let(:stub_body) { "some stub body" }

      it "returns the stub body" do
        expect(subject).to eql(stub_body)
      end

    end

    context "when the body is nil" do

      let(:stub_body) { nil }

      it "returns an empty string" do
        expect(subject).to eql("")
      end

    end

  end

end
