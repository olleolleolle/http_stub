module HttpStub
  module Models
    class RequestPipeline

      def self.before_halt(response)
        sleep response.delay_in_seconds if response.delay_in_seconds
      end
    end
  end
end