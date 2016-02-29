module HttpStub
  module Server
    module Scenario

      class Links

        def initialize(name)
          @name = name
        end

        def detail
          "/http_stub/scenarios?#{URI.encode_www_form(:name => @name)}"
        end

        def activate
          "/http_stub/scenarios/activate"
        end

      end
    end
  end
end
