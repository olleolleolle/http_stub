module Http
  module Stub

    class Registry

      def initialize
        @stubs = []
      end

      def add(stub, request)
        @stubs.unshift(stub)
        request.logger.info "Stub registered: #{stub}"
      end

      def find_for(request)
        request.logger.info "Finding stub fulfilling: #{request}"
        @stubs.find { |stub| stub.stubs?(request) }
      end

    end

  end
end
