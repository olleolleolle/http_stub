module HttpStub
  module Server
    module Application

      module SessionUriSupport

        def session_uri(uri)
          URI.add_parameters(uri, http_stub_session_id: http_stub_request.session.id)
        end

      end

    end
  end
end
