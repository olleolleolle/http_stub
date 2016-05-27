module HttpStub
  module Examples

    class ConfigurerWithRequestReferences
      include HttpStub::Configurer

      stub_server.add_stub! do |stub|
        stub.match_requests(uri:        "/some_path",
                            method:     :get,
                            headers:    { header_name: /.+/ },
                            parameters: { parameter_name: /.+/ })
        stub.respond_with do |request|
          {
            status:  200,
            headers: { header_referencing_header:    request.headers[:header_name],
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
