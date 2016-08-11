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

          def to_json(*args)
            { request: @request, response: @response, stub: @stub }.to_json(*args)
          end

        end

      end
    end
  end
end
