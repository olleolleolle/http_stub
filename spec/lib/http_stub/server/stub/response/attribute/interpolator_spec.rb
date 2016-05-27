describe HttpStub::Server::Stub::Response::Attribute::Interpolator do

  describe "::interpolate" do

    let(:value)   { "some value" }
    let(:request) { instance_double(HttpStub::Server::Request::Request) }

    subject { described_class.interpolate(value, request) }

    it "interpolates header references in the provided value" do
      expect(HttpStub::Server::Stub::Response::Attribute::Interpolator::Headers).to(
        receive(:interpolate).with(value, request).and_return("")
      )

      subject
    end

    it "combines the result of header interpolation to include parameter interpolation" do
      value_with_header_interpolation = "some value with header interpolation"
      allow(HttpStub::Server::Stub::Response::Attribute::Interpolator::Headers).to(
        receive(:interpolate).and_return(value_with_header_interpolation)
      )
      expect(HttpStub::Server::Stub::Response::Attribute::Interpolator::Parameters).to(
        receive(:interpolate).with(value_with_header_interpolation, request)
      )

      subject
    end

    it "returns the result of parameter interpolation as the overall result" do
      overall_result = "overall_result"
      allow(HttpStub::Server::Stub::Response::Attribute::Interpolator::Parameters).to(
        receive(:interpolate).and_return(overall_result)
      )

      expect(subject).to eql(overall_result)
    end

  end

end
