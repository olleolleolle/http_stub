describe HttpStub::Configurer::Server::Command do

  let(:http_request) { double("HttpRequest") }
  let(:request)      { double("HttpStubRequest", to_http_request: http_request) }
  let(:description)  { "Some Description" }
  let(:args)         { { request: request, description: description } }

  let(:command) { HttpStub::Configurer::Server::Command.new(args) }

  describe "#http_request" do

    it "returns the provided request adapted to a http request" do
      expect(command.http_request).to eql(http_request)
    end

  end

  describe "#description" do

    it "exposes the provided description" do
      expect(command.description).to eql(description)
    end

  end

end
