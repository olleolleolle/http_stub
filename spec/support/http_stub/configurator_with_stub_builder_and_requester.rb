shared_context "configurator with stub builder and requester" do

  let(:configurator) { HttpStub::Examples::ConfiguratorWithComprehensiveStubs }

  let(:stub_builder)   { configurator.stub_builder }
  let(:stub_requester) { HttpStub::StubRequester.new(server_uri, stub_builder) }

  let(:stub_match_rules)        { stub_builder.match_rules }
  let(:stub_response)           { stub_builder.response }
  let(:expected_match_response) { stub_requester.expected_response }

  let(:stub_request) { stub_requester.last_request }

end
