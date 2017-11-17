module HttpStub
  module Examples

    class ConfiguratorWithStubRequestBody
      include HttpStub::Configurator

      stub_server.add_scenario_with_one_stub!("Match body exactly") do
        match_requests(uri: "/match_body_exactly", method: :post, body: "Exactly matches")
        respond_with(status: 204)
      end

      stub_server.add_scenario_with_one_stub!("Match body regex") do
        match_requests(uri: "/match_body_regex", method: :post, body: /matches/)
        respond_with(status: 204)
      end

      stub_server.add_scenario_with_one_stub!("Match body JSON schema") do |stub|
        stub.match_requests(
          uri:    "/match_body_json_schema",
          method: :post,
          body:   stub.schema(:json, type: :object,
                                     properties: {
                                       string_property:  { type: :string },
                                       integer_property: { type: :integer, minimum: 0 },
                                       float_property:   { type: :number }
                                     },
                                     required: [ :float_property ]
                             )
        )
        stub.respond_with(status: 204)
      end

    end

  end
end
