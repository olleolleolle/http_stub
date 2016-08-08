module HttpStub
  module Server
    module Stub
      module Match

        class MissFixture

          def self.create
            HttpStub::Server::Stub::Match::Miss.new(HttpStub::Server::RequestFixture.create)
          end

        end

      end
    end
  end
end
