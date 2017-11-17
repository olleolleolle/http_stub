module HttpStub
  module Server
    module Stub
      module Match

        class MatchFixture

          def self.create
            HttpStub::Server::Stub::Match::Match.new(
              HttpStub::Server::RequestFixture.create,
              HttpStub::Server::Response::OK,
              HttpStub::Server::StubFixture.create
            )
          end

        end

      end
    end
  end
end
