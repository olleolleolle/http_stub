module HttpStub
  module Client

    class Server

      def initialize(base_uri)
        @base_uri = base_uri
      end

      def submit!(args)
        request = HttpStub::Client::Request.new(args.merge(base_uri: @base_uri))
        response = request.submit
        raise "#{request.error_message_prefix} #{response.code} #{response.message}" unless response.code == "200"
        response
      end

    end

  end
end
