module HttpStub
  module Server
    module Stub

      class RequestParameters

        def initialize(parameters)
          @parameters = HttpStub::Server::Stub::HashWithStringValueMatchers.new(parameters || {})
        end

        def match?(request)
          @parameters.match?(request.params)
        end

        def to_s
          @parameters ? @parameters.map { |key_and_value| key_and_value.map(&:to_s).join("=") }.join("&") : ""
        end

      end

    end
  end
end
