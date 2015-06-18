module HttpStub
  module Examples

    class ConfigurerWithStubRequestBody
      include HttpStub::Configurer

      stub_server.add_scenario!("match_body_exactly_scenario") do |scenario|
        scenario.add_stub! do |stub|
          stub.match_requests("/match_body_exactly", method: :post, body: "Exactly matches")
          stub.respond_with(status: 204)
        end
      end

      stub_server.add_scenario!("match_body_regex_scenario") do |scenario|
        scenario.add_stub! do |stub|
          stub.match_requests("/match_body_regex", method: :post, body: /matches/)
          stub.respond_with(status: 204)
        end
      end

      stub_server.add_scenario!("match_body_json_schema_scenario") do |scenario|
        scenario.add_stub! do |stub|
          stub.match_requests(
            "/match_body_json_schema", method: :post,
            body: stub.schema(:json, { type: :object,
                                       properties: {
                                         string_property:  { type: :string },
                                         integer_property: { type: :integer, minimum: 0 },
                                         float_property:   { type: :number }
                                       },
                                       required: [ :float_property ] })
          )
          stub.respond_with(status: 204)
        end

      end

    end

  end
end
