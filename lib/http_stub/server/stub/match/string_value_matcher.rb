module HttpStub
  module Server
    module Stub
      module Match

        class StringValueMatcher

          private

          MATCHERS = [ HttpStub::Server::Stub::Match::OmittedValueMatcher,
                       HttpStub::Server::Stub::Match::RegexpValueMatcher,
                       HttpStub::Server::Stub::Match::ExactValueMatcher ].freeze

          public

          def initialize(stub_value)
            @stub_match_value = stub_value ? stub_value.to_s : stub_value
          end

          def matches?(actual_value)
            !!MATCHERS.find { |matcher| matcher.match?(@stub_match_value, actual_value) }
          end

          def to_s
            @stub_match_value
          end

        end

      end
    end
  end
end
