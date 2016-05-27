module HttpStub
  module Server
    module Stub
      module Match

        class StringValueMatcher

          MATCHERS = [ HttpStub::Server::Stub::Match::OmittedValueMatcher,
                       HttpStub::Server::Stub::Match::RegexpValueMatcher,
                       HttpStub::Server::Stub::Match::ExactValueMatcher ].freeze

          private_constant :MATCHERS

          def self.match?(stub_value, actual_value)
            stub_match_value = stub_value ? stub_value.to_s : stub_value
            !!MATCHERS.find { |matcher| matcher.match?(stub_match_value, actual_value) }
          end

        end

      end
    end
  end
end
