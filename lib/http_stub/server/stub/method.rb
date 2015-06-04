module HttpStub
  module Server
    module Stub

      class Method

        def initialize(method)
          @method = method
        end

        def match?(request)
          @method.blank? || @method.downcase == request.request_method.downcase
        end

        def to_s
          @method || ""
        end

      end

    end
  end
end
