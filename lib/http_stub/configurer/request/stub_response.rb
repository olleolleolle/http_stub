module HttpStub
  module Configurer
    module Request

      class StubResponse

        def initialize(id, args)
          @id   = id
          @args = args
        end

        def payload
          {
            status:           @args[:status] || "",
            headers:          @args[:headers] || {},
            body:             @args[:body],
            delay_in_seconds: @args[:delay_in_seconds] || ""
          }
        end

        def file
          if contains_file?
            args = { id: @id, type: @args[:headers]["content-type"] }.merge(@args[:body][:file])
            HttpStub::Configurer::Request::StubResponseFile.new(args)
          else
            nil
          end
        end

        private

        def contains_file?
          @args[:body].is_a?(Hash) && @args[:body].key?(:file)
        end

      end

    end
  end
end
