describe HttpStub::Configurer::Server::Command do

  let(:request)     { double("HttpRequest") }
  let(:description) { "Some Description" }
  let(:args)        { { request: request, description: description } }

  let(:command) { HttpStub::Configurer::Server::Command.new(args) }

  describe "#request" do

    it "exposes the provided request" do
      expect(command.request).to eql(request)
    end

  end

  describe "#description" do

    it "exposes the provided description" do
      expect(command.description).to eql(description)
    end

  end

end
