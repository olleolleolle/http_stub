module HttpStub
  module Server
    module Stub
      module Match

        class MatchFixture

          def self.empty
            HttpStub::Server::Stub::Match::Match.new(nil, HttpStub::Server::RequestFixture.create)
          end

        end

      end
    end
  end
end
