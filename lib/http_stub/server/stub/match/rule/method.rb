module HttpStub
  module Server
    module Stub
      module Match
        module Rule

          class Method

            def initialize(method)
              @method = method
            end

            def matches?(request, _logger)
              @method.blank? || @method.casecmp(request.method) == 0
            end

            def to_s
              @method || ""
            end

          end

        end
      end
    end
  end
end
