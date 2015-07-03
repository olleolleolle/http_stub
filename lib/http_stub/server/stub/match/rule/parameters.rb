module HttpStub
  module Server
    module Stub
      module Match
        module Rule

          class Parameters

            def initialize(parameters)
              @parameters = HttpStub::Server::Stub::Match::HashWithStringValueMatchers.new(parameters || {})
            end

            def matches?(request, _logger)
              @parameters.matches?(request.parameters)
            end

            def to_s
              @parameters ? @parameters.map { |key_and_value| key_and_value.map(&:to_s).join("=") }.join("&") : ""
            end

          end

        end
      end
    end
  end
end
