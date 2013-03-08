module HttpStub
  module Models

    class Parameters

      def initialize(parameters)
        @parameters = parameters
      end

      def match?(request)
        request.params.has_hash?(@parameters)
      end

      def to_s
        @parameters ? @parameters.map { |key_and_value| key_and_value.join("=") }.join("&") : ""
      end

    end

  end
end
