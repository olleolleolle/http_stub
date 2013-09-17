module HttpStub
  module Models

    class Response

      private

      DEFAULT_OPTIONS = { "status" => 200, "delay_in_seconds" => 0 }

      def establish_defaults_in(options)
        DEFAULT_OPTIONS.each { |key, value| options[key] = value if !options[key] || options[key] == "" }
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

      def content_type
        @response_options["content_type"]
      end

      def empty?
        @original_options.empty?
      end

    end

  end
end
