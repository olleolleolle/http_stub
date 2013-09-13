module HttpStub
  module Models
    class RequestPipeline

      def before_halt(options = {})
        sleep options[:duration] if options[:duration] && options[:duration] > 0
      end
    end
  end
end