module HttpStub
  module Server
    module Stub
      module Match

        class ResultFixture

          def self.empty
            HttpStub::Server::Stub::Match::Result.new(
              HttpStub::Server::RequestFixture.create, HttpStub::Server::Response::NOT_FOUND, nil
            )
          end

        end

      end
    end
  end
end
