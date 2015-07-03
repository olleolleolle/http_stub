module HttpStub
  module Server

    class Request

      attr_reader :uri, :method, :headers, :parameters, :body

      def initialize(request)
        @uri        = request.path_info
        @method     = request.request_method.downcase
        @headers    = HttpStub::Server::FormattedHash.new(HttpStub::Server::HeaderParser.parse(request), ":")
        @parameters = HttpStub::Server::FormattedHash.new(request.params, "=")
        @body       = request.body.read
      end

    end

  end
end
