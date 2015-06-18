module HttpStub
  module Examples

    class ConfigurerWithSchemaValidatingStub
      include HttpStub::Configurer

      stub_server.add_scenario!("match_body_on_schema_request") do |scenario|
        scenario.add_stub! do |stub|
          stub.match_requests(
            "/matches_on_body_schema", method: :post,
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
