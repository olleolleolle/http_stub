module HttpStub
  module Models

    class Stub

      attr_reader :response

      def initialize(request_body)
        @data = JSON.parse(request_body)
        @response = HttpStub::Response.new(status: @data["response"]["status"], body: @data["response"]["body"])
      end

      def satisfies?(request)
        @data["uri"] == request.path_info &&
            @data["method"].downcase == request.request_method.downcase &&
            parameters_match?(request)
      end

      def to_s
        @data.to_s
      end

      private

      def parameters_match?(request)
        parameters = @data["parameters"]
        parameters.nil? || parameters.reduce(true) do |result, parameter|
          result && (request.params[parameter[0]] == parameter[1])
        end
      end

    end

  end
end
