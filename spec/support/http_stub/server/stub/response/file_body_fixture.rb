module HttpStub
  module Server
    module Stub
      module Response

        class FileBodyFixture

          class << self

            def args
              { file: { path: "#{HttpStub::Examples::RESOURCES_DIR}/example.txt" } }
            end

            def create
              HttpStub::Server::Stub::FileBody.new(args)
            end

          end

        end

      end
    end
  end
end
