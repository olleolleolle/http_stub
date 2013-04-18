module HttpStub
  module Models

    class StubParameters

      def initialize(parameters)
        @parameters = HttpStub::Models::HashWithRegexpableValues.new(parameters || {})
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
