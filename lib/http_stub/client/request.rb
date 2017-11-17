module HttpStub
  module Client

    class Request

      def initialize(args)
        @base_uri     = URI(args[:base_uri])
        @path         = args[:path]
        @method       = args[:method]
        @headers      = args[:headers] || {}
        @parameters   = args[:parameters]
        @http_options = args[:http_options] || {}
        @intent       = args[:intent]
      end

      def submit
        Net::HTTP.start(@base_uri.host, @base_uri.port, @http_options) { |http| http.request(http_request) }
      rescue StandardError => error
        raise "#{error_message_prefix} #{error}"
      end

      def error_message_prefix
        "Error occurred issuing request to #{@base_uri} - intent: #{@intent}, cause: "
      end

      private

      def http_request
        http_request_class = Net::HTTP.const_get(@method.to_s.capitalize)
        http_request_class.new("/http_stub/#{@path}", @headers.stringify_keys).tap do |request|
          request.set_form_data(@parameters) if @parameters
        end
      end

    end

  end
end
