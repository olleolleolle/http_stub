module HttpStub
  module Server
    module Stub
      module Match

        class Match

          attr_reader :stub, :request

          def initialize(stub, request)
            @stub    = stub || HttpStub::Server::Stub::Empty::INSTANCE
            @request = request
          end

        end

      end
    end
  end
end
