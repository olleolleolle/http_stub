describe HttpStub::Server::Stub::Response::Attribute::Interpolator::Parameters do

  describe "::interpolate" do

    let(:request_parameters) { instance_double(HttpStub::Server::Request::Parameters) }
    let(:request)            { instance_double(HttpStub::Server::Request::Request, parameters: request_parameters) }

    subject { described_class.interpolate(value, request) }

    context "when the value has parameter references" do

      let(:value) do
        "control:request.params[name1] some plain text control:request.headers[name1] control:request.params[name2]"
      end

      context "and the parameters are present in the request" do

        before(:example) do
          allow(request_parameters).to receive(:[]).with("name1").and_return("value1")
          allow(request_parameters).to receive(:[]).with("name2").and_return("value2")
        end

        it "returns the value with the parameter references interpolated" do
          expect(subject).to eql("value1 some plain text control:request.headers[name1] value2")
        end

      end

      context "and the parameters are not present in the request" do

        before(:example) { allow(request_parameters).to receive(:[]).and_return(nil) }

        it "returns the value with the parameter references removed" do
          expect(subject).to eql(" some plain text control:request.headers[name1] ")
        end

      end

    end

    context "when the value does not have parameter references" do

      let(:value) { "some value without parameter references control:request.headers[name1]" }

      it "returns the value unchanged" do
        expect(subject).to eql(value)
      end

    end

  end

end
