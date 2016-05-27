describe HttpStub::Configurer::DSL::RequestReferencer do

  let(:request_referencer) { described_class.new }

  before(:example) { allow(HttpStub::Configurer::DSL::RequestAttributeReferencer).to receive(:new) }

  describe "#params" do

    subject { request_referencer.params }

    it "returns an attribute request referencer for parameters" do
      parameter_referencer = instance_double(HttpStub::Configurer::DSL::RequestAttributeReferencer)
      allow(HttpStub::Configurer::DSL::RequestAttributeReferencer).to(
        receive(:new).with(:params).and_return(parameter_referencer)
      )

      expect(subject).to eql(parameter_referencer)
    end

  end

  describe "#headers" do

    subject { request_referencer.headers }

    it "returns an attribute request referencer for headers" do
      header_referencer = instance_double(HttpStub::Configurer::DSL::RequestAttributeReferencer)
      allow(HttpStub::Configurer::DSL::RequestAttributeReferencer).to(
        receive(:new).with(:headers).and_return(header_referencer)
      )

      expect(subject).to eql(header_referencer)
    end

  end

end
