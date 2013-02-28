module HttpStub
  module Models

    class Parameters

      def initialize(parameters)
        @parameters = parameters
      end

      def match?(request)
        @parameters.nil? || @parameters.reduce(true) do |result, parameter|
          result && (request.params[parameter[0]] == parameter[1])
        end
      end

      def to_s
        @parameters ? @parameters.map { |param| "#{param[0]}=#{param[1]}" }.join("&") : ""
      end

    end

  end
end
