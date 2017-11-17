module HttpStub
  module Server
    module Stub

      class Stub

        attr_reader :stub_id, :uri, :match_rules, :response, :triggers

        def initialize(hash)
          @stub_id      = hash[:id]
          @uri          = "/http_stub/stubs/#{@stub_id}"
          @match_rules  = HttpStub::Server::Stub::Match::Rules.new(hash[:match_rules])
          @response     = HttpStub::Server::Stub::Response.create(hash[:response])
          @triggers     = HttpStub::Server::Stub::Triggers.new(hash[:triggers])
          @description  = hash.to_s
        end

        def matches?(criteria, logger)
          criteria.is_a?(String) ? criteria == @stub_id : @match_rules.matches?(criteria, logger)
        end

        def response_for(request)
          @response.with_values_from(request)
        end

        def to_json(*args)
          {
            id:          @stub_id,
            uri:         @uri,
            match_rules: @match_rules,
            response:    @response,
            triggers:    @triggers
          }.to_json(*args)
        end

        def to_s
          @description
        end

      end

    end
  end
end
