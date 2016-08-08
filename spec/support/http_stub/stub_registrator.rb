module HttpStub

  class StubRegistrator

    attr_reader :request_uri, :request_method, :request_headers, :request_parameters, :request_body
    attr_reader :stub_response_status, :stub_response_headers, :stub_response_body

    def initialize(stub_server)
      @stub_server = stub_server

      @request_uri        = "/some/uri"
      @request_method     = "get"
      @request_headers    =
        (1..3).reduce({}) { |result, i| result.tap { result["request_header_#{i}"] = "request header value #{i}" } }
      @request_parameters = nil
      @request_body       = nil

      @stub_response_status  = 203
      @stub_response_headers =
        (1..3).reduce({}) { |result, i| result.tap { result["response_header_#{i}"] = "response header value #{i}" } }
      @stub_response_body    = "Stub response body"
      @stub_response_block   = lambda do |_request|
        { status:  @stub_response_status, headers: @stub_response_headers, body: @stub_response_body }
      end
    end

    def with_request_parameters
      @request_parameters =
        (1..3).reduce({}) { |result, i| result.tap { result["parameter_#{i}"] = "parameter value #{i}" } }
    end

    def with_request_body
      @request_body = "Some <strong>request body</strong>"
    end

    def with_request_interpolation
      @stub_response_block = lambda do |request|
        {
          status:  @stub_response_status,
          headers: { header_reference:    request.headers[:request_header_2],
                     parameter_reference: request.parameters[:parameter_2] },
          body:    "header: #{request.headers[:request_header_3]}, " \
                   "parameter: #{request.parameters[:parameter_3]}"
        }
      end
    end

    def register_stub
      @register_stub_response = @stub_server.add_stub!(build_stub)
    end

    def register_scenario
      @stub_server.add_scenario_with_one_stub!("Some scenario", build_stub)
    end

    def stub_uri
      @register_stub_response.header["location"]
    end

    def last_match(uri, method)
      HTTParty.get("#{@stub_server.base_uri}/http_stub/stubs/matches/last", query: { uri: uri, method: method })
    end

    def issue_matching_request
      options         = { headers: @request_headers }
      options[:query] = @request_parameters if @request_parameters
      options[:body]  = @request_body if @request_body
      HTTParty.send(request_method, "#{@stub_server.base_uri}#{@request_uri}", options)
    end

    private

    def build_stub
      @stub_server.build_stub do |stub|
        stub.match_requests(uri: @request_uri, method: @request_method,
                            headers: @request_headers, parameters: @request_parameters, body: @request_body)
        stub.respond_with(&@stub_response_block)
      end
    end

  end

end
