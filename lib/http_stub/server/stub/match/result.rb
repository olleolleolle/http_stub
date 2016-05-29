module HttpStub
  module Server
    module Stub
      module Match

        class Result

          attr_reader :request, :response, :stub

          def initialize(request, response, stub)
            @request  = request
            @response = response
            @stub     = stub
          end

        end

      end
    end
  end
end
