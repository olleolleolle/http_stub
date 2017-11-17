module HttpStub
  module Examples

    class ConfiguratorWithResponseBlocks
      include HttpStub::Configurator

      some_path_template = stub_server.endpoint_template do |template|
        template.match_requests(uri:        "/some_path",
                                method:     :get,
                                headers:    { header_name: /.+/ },
                                parameters: { parameter_name: /.+/ })
        template.respond_with do
          {
            status:  400,
            headers: { "header_defaulted"          => "some default header value",
                       "header_overridden"         => "some initial header value",
                       "header_referencing_header" => "some default reference value" },
            body:    "some default body"
          }
        end
      end

      some_path_template.add_stub! do |stub|
        stub.respond_with do |request|
          {
            status:  201,
            headers: { header_overridden:            "some overridden header value",
                       header_referencing_header:    request.headers[:header_name],
                       header_referencing_parameter: request.parameters[:parameter_name] },
            body:    <<-BODY
              header_name = #{request.headers[:header_name]}
              parameter_name = #{request.parameters[:parameter_name]}
            BODY
          }
        end
      end

    end

  end
end
