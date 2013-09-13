module HttpStub
  module Models
    class RequestPipeline

      def before_halt(options = {})
        sleep options[:delay_in_seconds] if options[:delay_in_seconds] && options[:delay_in_seconds] > 0
      end
    end
  end
end