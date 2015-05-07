module HttpStub
  module Configurer
    module Request

      class PlainHttp

        def initialize(http_request)
          @http_request = http_request
        end

        def to_http_request
          @http_request
        end

      end

    end
  end
end
