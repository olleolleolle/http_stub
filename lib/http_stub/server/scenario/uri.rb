module HttpStub
  module Server
    module Scenario

      class Uri

        def self.create(name)
          "/http_stub/scenarios/activate?#{ URI.encode_www_form(:name => name) }"
        end

      end
    end
  end
end
