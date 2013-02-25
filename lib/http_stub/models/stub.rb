module HttpStub
  module Models

    class Stub

      attr_reader :response

      def initialize(options)
        @alias_options = options
        @response = HttpStub::Response.new(options["response"])
      end

      def satisfies?(request)
        uri == request.path_info &&
            method.downcase == request.request_method.downcase &&
            parameters_match?(request)
      end

      def uri
        @alias_options["uri"]
      end

      def method
        @alias_options["method"]
      end

      def to_s
        @alias_options.to_s
      end

      private

      def parameters_match?(request)
        parameters = @alias_options["parameters"]
        parameters.nil? || parameters.reduce(true) do |result, parameter|
          result && (request.params[parameter[0]] == parameter[1])
        end
      end

    end

  end
end
