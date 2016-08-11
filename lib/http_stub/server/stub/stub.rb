module HttpStub
  module Server
    module Stub

      class Stub

        attr_reader :uri, :match_rules, :response, :triggers

        def initialize(args)
          @id          = args["id"] || SecureRandom.uuid
          @uri         = "#{args["base_uri"]}/http_stub/stubs/#{@id}"
          @match_rules = HttpStub::Server::Stub::Match::Rules.new(args)
          @response    = HttpStub::Server::Stub::Response.create(args["response"])
          @triggers    = HttpStub::Server::Stub::Triggers.new(args["triggers"])
          @description = args.to_s
        end

        def matches?(criteria, logger)
          criteria.is_a?(String) ? criteria == @id : @match_rules.matches?(criteria, logger)
        end

        def response_for(request)
          @response.with_values_from(request)
        end

        def to_json(*args)
          { id: @id, uri: @uri, match_rules: @match_rules, response: @response, triggers: @triggers }.to_json(*args)
        end

        def to_s
          @description
        end

      end

    end
  end
end
