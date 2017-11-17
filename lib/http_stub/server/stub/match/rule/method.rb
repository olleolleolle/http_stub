module HttpStub
  module Server
    module Stub
      module Match
        module Rule

          class Method

            def initialize(method)
              @method = method.try(:to_s).try(:upcase)
            end

            def matches?(request, _logger)
              @method.blank? || @method.casecmp(request.method).zero?
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
