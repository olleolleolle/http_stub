module HttpStub
  module Examples

    class StubBuilder

      attr_reader :match_rules
      attr_reader :response

      def initialize(stub_server=nil)
        @stub_server = stub_server
        @match_rules = defaults_match_rules
        @response    = default_response
      end

      def with_request_parameters!
        @match_rules[:uri] += "/with_request_parameters"
        @match_rules[:parameters] =
          (1..3).each_with_object({}) { |i, result| result["parameter_#{i}"] = "parameter value #{i}" }
        self
      end

      def with_request_body!
        @match_rules[:uri] += "/with_request_body"
        @match_rules[:body] = "Some <strong>request body</strong>"
        self
      end

      def with_request_interpolation!
        @match_rules[:uri] += "/with_request_interpolation"
        @response[:block] = lambda do |request|
          {
            status:  203,
            headers: { header_reference:    request.headers[:request_header_2],
                       parameter_reference: request.parameters[:parameter_2] },
            body:    "header: #{request.headers[:request_header_3]}, parameter: #{request.parameters[:parameter_3]}"
          }
        end
        self
      end

      def and
        self
      end

      def build
        @built_stub ||= @stub_server.build_stub do |stub|
          stub.match_requests(@match_rules)
          response_args  = @response.clone
          response_block = response_args.delete(:block)
          response_block ? stub.respond_with(response_args, &response_block) : stub.respond_with(response_args)
        end
      end

      def stub_uri
        "/http_stub/stubs/#{build.id}"
      end

      def response_for(request)
        @response[:block] ? @response[:block].call(request) : @response
      end

      private

      def defaults_match_rules
        headers = (1..3).each_with_object({}) { |i, hash| hash["request_header_#{i}"] = "request header value #{i}" }
        { uri: "/some/stub", method: "get", headers: headers, parameters: {}, body: "" }
      end

      def default_response
        headers = (1..3).each_with_object({}) { |i, hash| hash["response_header_#{i}"] = "response header value #{i}" }
        { status: 201, headers: headers, body: "Some response body" }
      end

    end

  end
end
