describe HttpStub::Server::Stub::Response::Attribute::Interpolator::Headers do

  describe "::interpolate" do

    let(:request_headers) { instance_double(HttpStub::Server::Request::Headers) }
    let(:request)         { instance_double(HttpStub::Server::Request::Request, headers: request_headers) }

    subject { described_class.interpolate(value, request) }

    context "when the value has header references" do

      let(:value) do
        "control:request.headers[name1] some plain text control:request.params[name1] control:request.headers[name2]"
      end

      context "and the headers are present in the request" do

        before(:example) do
          allow(request_headers).to receive(:[]).with("name1").and_return("value1")
          allow(request_headers).to receive(:[]).with("name2").and_return("value2")
        end

        it "returns the value with the header references interpolated" do
          expect(subject).to eql("value1 some plain text control:request.params[name1] value2")
        end

      end

      context "and the headers are not present in the request" do

        before(:example) { allow(request_headers).to receive(:[]).and_return(nil) }

        it "returns the value with the header references removed" do
          expect(subject).to eql(" some plain text control:request.params[name1] ")
        end

      end

    end

    context "when the value does not have header references" do

      let(:value) { "some value without header references control:request.params[name1]" }

      it "returns the value unchanged" do
        expect(subject).to eql(value)
      end

    end

  end

end
