module HttpStub
  module Server
    module Stub

      class Empty

        private

        def initialize
          @uri = @method = @body = @stub_uri = ""
          @headers = @parameters             = {}
          @triggers                          = []
          @response                          = HttpStub::Server::Response::EMPTY
        end

        public

        attr_reader :uri, :method, :headers, :parameters, :body, :response, :triggers, :stub_uri

        def matches?(_criteria, _logger)
          false
        end

        def response_for(_request)
          self
        end

        def to_s
          ""
        end

        INSTANCE = self.new.freeze

      end

    end
  end
end
