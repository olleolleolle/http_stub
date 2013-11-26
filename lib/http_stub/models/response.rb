module HttpStub
  module Models

    class Response

      private

      DEFAULT_OPTIONS = { "status" => 200, "delay_in_seconds" => 0 }.freeze
      DEFAULT_HEADERS = { "content-type" => "application/json" }.freeze

      def establish_defaults_in(options)
        headers = options["headers"] ||= {}
        DEFAULT_OPTIONS.each { |key, value| options[key] = value if !options[key] || options[key] == "" }
        DEFAULT_HEADERS.each { |key, value| headers[key] = value if !headers[key] || headers[key] == "" }
      end

      public

      def initialize(options = {})
        @original_options = options
        @response_options = options.clone
        establish_defaults_in(@response_options)
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

      def headers
        @response_options["headers"]
      end

      def empty?
        @original_options.empty?
      end

    end

  end
end
