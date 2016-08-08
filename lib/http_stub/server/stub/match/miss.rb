module HttpStub
  module Server
    module Stub
      module Match

        class Miss

          attr_reader :request

          def initialize(request)
            @request = request
          end

        end

      end
    end
  end
end
