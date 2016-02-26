module HttpStub
  module Examples

    class AuthenticationServiceConfigurer
      include HttpStub::Configurer

      login_template = stub_server.endpoint_template { match_requests(uri: "/login", method: :post) }

      login_template.add_scenario!("Grant Access", status: 200)
      login_template.add_scenario!("Deny Access",  status: 401)

    end

  end
end
