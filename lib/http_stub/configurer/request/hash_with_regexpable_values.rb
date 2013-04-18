module HttpStub
  module Configurer
    module Request

      class HashWithRegexpableValues

        def initialize(hash)
          @hash = hash.reduce({}) do |result, entry|
            result[entry[0]] = HttpStub::Configurer::Request::RegexpableValue.new(entry[1])
            result
          end
        end

        def to_json(*args)
          @hash.to_json(args)
        end

      end

    end
  end
end
