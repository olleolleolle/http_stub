module HttpStub
  module Models
    class RequestPipeline

      def before_halt(response)
        delay_in_seconds = response.delay_in_seconds
        sleep delay_in_seconds if delay_in_seconds && delay_in_seconds > 0
      end
    end
  end
end