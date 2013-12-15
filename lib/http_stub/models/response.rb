module HttpStub
  module Models

    class Response

      private

      DEFAULT_ARGS = { "status" => 200, "delay_in_seconds" => 0 }.freeze
      DEFAULT_HEADERS = { "content-type" => "application/json" }.freeze

      def merge_default_arguments(args)
        args.clone.tap do |result|
          headers = result["headers"] ||= {}
          DEFAULT_ARGS.each { |key, value| result[key] = value if !result[key] || result[key] == "" }
          DEFAULT_HEADERS.each { |key, value| headers[key] = value if !headers[key] || headers[key] == "" }
        end
      end

      public

      attr_reader :status, :body, :delay_in_seconds, :headers

      def initialize(args={})
        @original_args = args
        resolved_args = merge_default_arguments(args)
        @status = resolved_args["status"]
        @body = resolved_args["body"]
        @delay_in_seconds = resolved_args["delay_in_seconds"]
        @headers = HttpStub::Models::Headers.new(resolved_args["headers"])
      end

      SUCCESS = HttpStub::Models::Response.new("status" => 200, "body" => "OK")
      ERROR = HttpStub::Models::Response.new("status" => 404, "body" => "ERROR")
      EMPTY = HttpStub::Models::Response.new()

      def empty?
        @original_args.empty?
      end

    end

  end
end
