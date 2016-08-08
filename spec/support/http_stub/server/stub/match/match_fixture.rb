module HttpStub
  module Server
    module Stub
      module Match

        class MatchFixture

          def self.create
            HttpStub::Server::Stub::Match::Match.new(
              HttpStub::Server::RequestFixture.create,
              HttpStub::Server::Response::OK,
              HttpStub::Server::Stub::Stub.new(HttpStub::StubFixture.new.server_payload)
            )
          end

        end

      end
    end
  end
end
