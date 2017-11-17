module HttpStub
  module Server
    module Stub
      module Response

        class Body

          def self.create(args)
            if args[:body].is_a?(Hash)
              HttpStub::Server::Stub::Response::FileBody.new(args[:body])
            else
              HttpStub::Server::Stub::Response::TextBody.new(args)
            end
          end

        end

      end
    end
  end
end
