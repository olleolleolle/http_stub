module HttpStub
  module Configurer
    module Server

      class Command

        attr_reader :description

        def initialize(args)
          @request     = args[:request]
          @description = args[:description]
        end

        def http_request
          @request.to_http_request
        end

      end

    end
  end
end
