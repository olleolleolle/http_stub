describe HttpStub::Server::Stub::Response do

  describe "::create" do

    let(:status)           { 201 }
    let(:headers)          { HttpStub::HeadersFixture.many }
    let(:body)             { "some text" }
    let(:delay_in_seconds) { 8 }
    let(:blocks)           { HttpStub::Server::Stub::Response::BlocksFixture.many }
    let(:args)             do
      { status: 201, headers: headers, body: body, delay_in_seconds: delay_in_seconds, blocks: blocks }
    end

    let(:primitive_response) { JSON.parse(subject.to_json).symbolize_keys }

    subject { HttpStub::Server::Stub::Response.create(args) }

    it "creates a response with the provided status" do
      expect(primitive_response).to include(status: status)
    end

    it "creates a response with the provided headers" do
      expect(primitive_response).to include(headers: headers)
    end

    it "creates a response with the provided body" do
      expect(primitive_response).to include(body: body)
    end

    it "creates a response with the provided delay in seconds" do
      expect(primitive_response).to include(delay_in_seconds: delay_in_seconds)
    end

    it "creates a response with the provided blocks" do
      expect(primitive_response[:blocks]).to eql(blocks.map(&:source))
    end

  end

end
