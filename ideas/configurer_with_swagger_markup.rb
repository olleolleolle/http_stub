module HttpStub
  module Examples

    class ConfigurerWithSwaggerConcept
      include HttpStub::Configurer

      view_endpoint = stub_server.endpoint(description: "Retrieves details of a resource") do |endpoint|
        endpoint.match_requests(uri:        %r{/some/endpoint/\{id:/d+\}},
                                method:     :get,
                                headers:    {
                                  some_mandatory_header: {
                                    description: "a mandatory header",
                                    type:        :string,
                                    format:      /.+/
                                  }
                                },
                                parameters: {
                                  some_mandatory_parameter: {
                                    description: "a mandatory parameter",
                                    type:        :number,
                                    format:      /\d{2}/
                                  }
                                })
        endpoint.respond_with(status:  200,
                              headers: { some_default_header: // },
                              body:    "some default body")
      end

      view_endpoint.add_scenario!("View Resource: valid") do |stub|
        stub.respond_with(body: "this is the valid resource")
      end

      view_endpoint.add_scenario!("View Resource: with umlaut characters") do |stub|
        stub.respond_with(body: "Über")
      end

      view_endpoint.add_scenario!("View Resource: without some_mandatory_header header") do |stub|
        stub.match_requests(headers: { some_mandatory_header: :omitted })
        stub.respond_with(status: 400,
                          body:   "some_mandatory_header is mandatory")
      end

      update_endpoint = stub_server.endpoint(description: "Updates a resource") do |endpoint|
        endpoint.match_requests(uri:    %r{/some/endpoint/\{id:/d+\}},
                                method: :put,
                                body:   stub.schema(:json, type: :object,
                                                    properties: {
                                                      string_property:  { type: :string },
                                                      integer_property: { type: :integer, minimum: 0 },
                                                      float_property:   { type: :number }
                                                    },
                                                    required: [ :float_property ]))
        endpoint.respond_with(status: 200)
      end

      update_endpoint.add_scenario!("Update Resource: valid") do |stub|
        stub.respond_with(json: { string_property:  "some string",
                                  integer_property: 8,
                                  float_property:   8.8 })
      end

      # Problems & Challenges:
      # - http_stub DSL becomes more verbose and complex:
      # -- Endpoint definitions
      # -- Response status description definitions - what should these be?
      # - Re-usable request and response objects - is this desirable?
      # - Examples of inputs; should this only be possible for exact match scenarios?
      # - JSON Schema definition for response - this is difficult to infer from responses (lossy approaches exist)

    end

  end
end
