module HttpStub
  module Models

    class ResponsePipeline

      def initialize(server)
        @server = server
      end

      def process(response)
        sleep response.delay_in_seconds
        response.serve_on(@server)
      end

    end

  end
end
