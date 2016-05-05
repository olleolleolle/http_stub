module HttpStub
  module Examples
    module AuthenticationService

      class Configurer
        include HttpStub::Configurer

        login_template = stub_server.endpoint_template { match_requests(uri: "/login", method: :post) }

        login_template.add_scenario!("Grant access", status: 200)
        login_template.add_scenario!("Deny access",  status: 401)
      end

    end
  end
end
