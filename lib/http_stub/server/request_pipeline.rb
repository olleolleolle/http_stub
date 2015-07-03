module HttpStub
  module Server

    class RequestPipeline

      def initialize(stub_controller, scenario_controller, match_registry)
        @stub_controller     = stub_controller
        @scenario_controller = scenario_controller
        @match_registry      = match_registry
      end

      def process(request, logger)
        response = @stub_controller.replay(request, logger)
        response = @scenario_controller.activate(request, logger) if response.empty?
        response.empty? ? process_unmatched(request, logger) : response
      end

      private

      def process_unmatched(request, logger)
        @match_registry.add(HttpStub::Server::Stub::Match::Match.new(nil, request), logger)
        HttpStub::Server::Response::NOT_FOUND
      end
    end

  end
end
