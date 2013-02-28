module HttpStub
  module Models

    class Stub

      attr_reader :response

      def initialize(options)
        @stub_options = options
        @parameters = HttpStub::Models::Parameters.new(options["parameters"])
        @response = HttpStub::Response.new(options["response"])
      end

      def satisfies?(request)
        uri == request.path_info && method.downcase == request.request_method.downcase && @parameters.match?(request)
      end

      def uri
        @stub_options["uri"]
      end

      def method
        @stub_options["method"]
      end

      def parameters
        @parameters
      end

      def to_s
        @stub_options.to_s
      end

    end

  end
end
