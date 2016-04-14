module HttpStub
  module Server
    module Stub
      module Match

        class Result

          attr_reader :request, :stub

          def initialize(request, stub)
            @request = request
            @stub    = stub
          end

        end

      end
    end
  end
end
