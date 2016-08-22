module HttpStub
  module Configurer
    module Request

      class Stub

        def initialize(args)
          @id       = SecureRandom.uuid
          @request  = args[:request]
          @response = HttpStub::Configurer::Request::StubResponse.new(@id, args[:response])
          @triggers = HttpStub::Configurer::Request::Triggers.new(args[:triggers])
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
            triggers:   @triggers.payload
          }
        end

        def response_files
          ([ @response.file ] + @triggers.response_files).compact
        end

        def to_s
          @request[:uri]
        end

      end

    end
  end
end
