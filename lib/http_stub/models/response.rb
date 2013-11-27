module HttpStub
  module Models

    class Response

      private

      DEFAULT_OPTIONS = { "status" => 200, "delay_in_seconds" => 0 }.freeze
      DEFAULT_HEADERS = { "content-type" => "application/json" }.freeze

      def merge_default_options(options)
        options.clone.tap do |options|
          headers = options["headers"] ||= {}
          DEFAULT_OPTIONS.each { |key, value| options[key] = value if !options[key] || options[key] == "" }
          DEFAULT_HEADERS.each { |key, value| headers[key] = value if !headers[key] || headers[key] == "" }
        end
      end

      public

      attr_reader :status, :body, :delay_in_seconds, :headers

      def initialize(options = {})
        @original_options = options
        resolved_options = merge_default_options(options)
        @status = resolved_options["status"]
        @body = resolved_options["body"]
        @delay_in_seconds = resolved_options["delay_in_seconds"]
        @headers = HttpStub::Models::Headers.new(resolved_options["headers"])
      end

      SUCCESS = HttpStub::Models::Response.new("status" => 200, "body" => "OK")
      ERROR = HttpStub::Models::Response.new("status" => 404, "body" => "ERROR")
      EMPTY = HttpStub::Models::Response.new()

      def empty?
        @original_options.empty?
      end

    end

  end
end
