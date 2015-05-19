module HttpStub
  module Server

    class StringValueMatcher

      private

      MATCHERS = [ HttpStub::Server::OmittedValueMatcher,
                   HttpStub::Server::RegexpValueMatcher,
                   HttpStub::Server::ExactValueMatcher ].freeze

      public

      def initialize(stub_value)
        @stub_match_value = stub_value ? stub_value.to_s : stub_value
      end

      def match?(actual_value)
        !!MATCHERS.find { |matcher| matcher.match?(@stub_match_value, actual_value) }
      end

      def to_s
        @stub_match_value
      end

    end

  end
end
