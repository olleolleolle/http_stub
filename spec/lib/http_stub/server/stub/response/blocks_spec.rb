describe HttpStub::Server::Stub::Response::Blocks do

  let(:provided_blocks) { HttpStub::Server::Stub::Response::BlocksFixture.many }

  let(:blocks) { described_class.new(provided_blocks) }

  describe "#each" do

    it "yields each provided block" do
      yielded_blocks = []
      blocks.each { |block| yielded_blocks << block }

      expect(yielded_blocks).to eql(provided_blocks)
    end

  end

  describe "#evaluate_with" do

    let(:parameter_value) { "some parameter value" }
    let(:parameters)      { { some_parameter: parameter_value } }
    let(:request)         { HttpStub::Server::RequestFixture.create(parameters: parameters) }

    let(:provided_blocks) do
      [
        lambda { |request| { key: "value with parameter: #{request.parameters[:some_parameter]}" } },
        lambda { { hash: { nested_key: "nested value", another_nested_key: "another nested value" } } },
        lambda { { hash: { nested_key: "new nested value", yet_another_nested_key: "yet another nested value" } } }
      ]
    end

    subject { blocks.evaluate_with(request) }

    it "merges the hashes composed by each block" do
      expect(subject.keys).to eql(%i{ key hash })
    end

    it "interpolates values from the request" do
      expect(subject).to include(key: "value with parameter: #{parameter_value}")
    end

    it "performs a nested merge of the hashes" do
      expected_hash = {
        nested_key:             "new nested value",
        another_nested_key:     "another nested value",
        yet_another_nested_key: "yet another nested value"
      }

      expect(subject).to include(hash: expected_hash)
    end

  end

  describe "#to_array" do

    subject { blocks.to_array }

    it "returns the source of the provided blocks" do
      expect(subject).to eql(provided_blocks.map(&:source))
    end

  end

end
