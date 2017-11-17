module HttpStub

  class StubRequester

    attr_reader :last_request

    def initialize(server_uri, stub_builder)
      @server_uri   = server_uri
      @stub_builder = stub_builder
    end

    def expected_response
      @stub_builder.response_for(HttpStub::Server::SimpleRequest.new(@stub_builder.match_rules))
    end

    def issue_matching_request
      issue_request({})
    end

    def issue_non_matching_request
      issue_request(headers: { "some_header" => "does not match" })
    end

    private

    def issue_request(overrides)
      request = @stub_builder.match_rules.merge(overrides)
      options = {}
      options[:headers] = request[:headers] if request[:headers]
      options[:query]   = request[:parameters] if request[:parameters]
      options[:body]    = request[:body] if request[:body]
      HTTParty.send(request[:method], "#{@server_uri}#{request[:uri]}", options).tap { @last_request = request }
    end

  end

end
