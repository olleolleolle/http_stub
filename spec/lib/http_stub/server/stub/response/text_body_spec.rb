describe HttpStub::Server::Stub::Response::TextBody do

  let(:args) { HttpStub::Server::Stub::Response::TextBodyFixture.args_with_body }

  let(:text_body) { described_class.new(args) }

  describe "#headers" do

    subject { text_body.headers }

    context "when a json argument is provided" do

      let(:args) { HttpStub::Server::Stub::Response::TextBodyFixture.args_with_json }

      it "includes a content-type of application/json" do
        expect(subject).to include("content-type" => "application/json")
      end

    end

    context "when a body is provided" do

      let(:args) { HttpStub::Server::Stub::Response::TextBodyFixture.args_with_body }

      it "returns an empty hash" do
        expect(subject).to eql({})
      end

    end

    context "when neither a json argument or body is provided" do

      let(:args) { {} }

      it "returns an empty hash" do
        expect(subject).to eql({})
      end

    end

  end

  describe "#text" do

    subject { text_body.text }

    context "when a json argument is provided" do

      let(:args) { HttpStub::Server::Stub::Response::TextBodyFixture.args_with_json(json_value) }

      context "that converts to json" do

        let(:json_value) { "some json value" }

        it "returns the json representation of the argument" do
          expect(subject).to eql(json_value)
        end

      end

      context "that does not convert to json" do

        let(:json_value) { nil }

        it "returns an empty string" do
          expect(subject).to eql("")
        end

      end

    end

    context "when a body is provided" do

      let(:args) { HttpStub::Server::Stub::Response::TextBodyFixture.args_with_body }

      it "returns the body value" do
        expect(subject).to eql(args[:body])
      end

    end

    context "when neither JSON or a body is provided" do

      let(:args) { {} }

      it "returns an empty string" do
        expect(subject).to eql("")
      end

    end

  end

  describe "#serve" do

    let(:application) { instance_double(Sinatra::Base) }
    let(:response)    { HttpStub::Server::Stub::ResponseBuilder.new.with_headers!.build }

    subject { text_body.serve(application, response) }

    it "halts processing of the applications request" do
      expect(application).to receive(:halt)

      subject
    end

    it "halts with the responses status" do
      expect(application).to receive(:halt).with(response.status, anything, anything)

      subject
    end

    it "halts with the hash representation of the responses headers" do
      expect(application).to receive(:halt).with(anything, response.headers, anything)

      subject
    end

    it "halts with the text bodys text" do
      expect(application).to receive(:halt).with(anything, anything, text_body.text)

      subject
    end

  end

  describe "#to_s" do

    subject { text_body.to_s }

    it "returns the text" do
      expect(subject).to eql(text_body.text)
    end

  end

end
