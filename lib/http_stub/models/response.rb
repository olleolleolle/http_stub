module HttpStub
  module Models

    class Response

      def initialize(options = {})
        @response_options = options || {}
      end

      SUCCESS = HttpStub::Models::Response.new("status" => 200, "body" => "OK")
      ERROR = HttpStub::Models::Response.new("status" => 404, "body" => "ERROR")
      EMPTY = HttpStub::Models::Response.new()

      def status
        @response_options["status"]
      end

      def body
        @response_options["body"]
      end

      def delay_in_seconds
        @response_options["delay_in_seconds"]
      end

      def empty?
        @response_options.empty?
      end
    end

  end
end
