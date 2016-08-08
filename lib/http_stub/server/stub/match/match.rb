module HttpStub
  module Server
    module Stub
      module Match

        class Match

          attr_reader :request, :response, :stub

          def initialize(request, response, stub)
            @request  = request
            @response = response
            @stub     = stub
          end

          def matches?(criteria, _logger)
            @request.uri.include?(criteria[:uri]) && @request.method.casecmp(criteria[:method]).zero?
          end

          def to_hash
            { request: @request, response: @response, stub: @stub }
          end

        end

      end
    end
  end
end
