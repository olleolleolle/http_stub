module HttpStub
  module Configurer
    module Request

      class Stub

        def initialize(args)
          @id       = SecureRandom.uuid
          @request  = args[:request]
          @response = HttpStub::Configurer::Request::StubResponse.new(@id, args[:response])
          @triggers = args[:triggers].map(&:build)
        end

        def payload
          {
            id:         @id,
            uri:        HttpStub::Configurer::Request::ControllableValue.format(@request[:uri]),
            method:     @request[:method],
            headers:    HttpStub::Configurer::Request::ControllableValue.format(@request[:headers] || {}),
            parameters: HttpStub::Configurer::Request::ControllableValue.format(@request[:parameters] || {}),
            body:       HttpStub::Configurer::Request::ControllableValue.format(@request[:body] || {}),
            response:   @response.payload,
            triggers:   @triggers.map(&:payload)
          }
        end

        def response_files
          ([ @response.file ] + @triggers.map(&:response_files)).flatten.compact
        end

        def to_s
          @request[:uri]
        end

      end

    end
  end
end
