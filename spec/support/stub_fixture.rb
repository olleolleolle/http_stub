module HttpStub

  class StubFixture

    attr_reader :id, :request, :response

    class Part

      attr_writer :payload

      def initialize(payload)
        @payload = payload
      end

      def merge!(options)
        @payload.merge!(options)
      end

      def symbolized
        @payload
      end

      def stringified
        JSON.parse(@payload.to_json)
      end

      def http_method
        @payload[:method]
      end

      def method_missing(name, *args)
        if name.to_s.end_with?("=")
          attribute_name = name.to_s[0..-2].to_sym
          @payload[attribute_name] = args.first
        else
          @payload[name]
        end
      end

    end

    def initialize
      @id = SecureRandom.uuid
      @request = HttpStub::StubFixture::Part.new(
        uri:        "/stub/uri/#{@id}",
        method:     "some #{@id} method",
        headers:    { "request_header_name" => "request header value #{@id}" },
        parameters: { "parameter_name" => "request parameter value #{@id}" }
      )
      @response = HttpStub::StubFixture::Part.new(
        status:           500,
        headers:          { "response_header_name" => "response header value #{@id}" },
        body:             "body #{@id}",
        delay_in_seconds: 8
      )
      @trigger_fixtures = []
    end

    def response=(options)
      self.tap { @response.payload = options }
    end

    def with_response!(options)
      self.tap { @response.merge!(options) }
    end

    def with_text_response!
      with_response!(body: "payload #{@id} text response")
    end

    def with_file_response!
      with_response!(body: { file: { path: "payload/#{@id}/file.path",
                                     name: "payload_#{@id}_file.name" } })
    end

    def with_triggers!(triggers)
      self.tap { @trigger_fixtures.concat(triggers) }
    end

    def configurer_payload
      {
        request:  @request.symbolized,
        response: @response.symbolized,
        triggers: @trigger_fixtures.map(&:configurer_payload)
      }
    end

    def server_payload
      {
        "id"         => @id,
        "uri"        => @request.uri,
        "method"     => @request.http_method,
        "headers"    => @request.headers,
        "parameters" => @request.parameters,
        "response"   => @response.stringified,
        "triggers"   => @trigger_fixtures.map(&:server_payload)
      }
    end

    def file_parameter
      @file_parameter ||= { filename: "#{@id}.payload", tempfile: StringIO.new("payload #{@id} content") }
    end

  end

end
