module HttpStub
  module Server
    module Stub

      class Empty

        private

        def initialize
          @uri         = ""
          @match_rules = HttpStub::Server::Stub::Match::Rules::EMPTY
          @response    = HttpStub::Server::Response::EMPTY
          @triggers    = HttpStub::Server::Stub::Triggers::EMPTY
        end

        public

        attr_reader :uri, :match_rules, :response, :triggers

        def matches?(_criteria, _logger)
          false
        end

        def response_for(_request)
          self
        end

        def to_hash
          {}
        end

        def to_s
          ""
        end

        INSTANCE = self.new.freeze

      end

    end
  end
end
