module HttpStub
  module Configurator

    class StubBuilder

      attr_reader :match_rules, :response, :triggers

      class Part

        attr_writer :hash

        def initialize(hash)
          @hash = hash.with_indifferent_access
        end

        def merge!(options)
          @hash.merge!(options)
        end

        def http_method
          @hash[:method]
        end

        def to_hash
          @hash
        end

        def method_missing(name, *args)
          if name.to_s.end_with?("=")
            attribute_name = name.to_s[0..-2].to_sym
            @hash[attribute_name] = args.first
          else
            @hash[name]
          end
        end

      end

      def initialize
        @unique_value = SecureRandom.uuid
        @match_rules = HttpStub::Configurator::StubBuilder::Part.new(
          uri:        "/stub/uri/#{@unique_value}",
          method:     "some #{@unique_value} method",
          headers:    { "request_header_name" => "request header value #{@unique_value}" },
          parameters: { "parameter_name" => "parameter value #{@unique_value}" },
          body:       "some body"
        )
        @response = HttpStub::Configurator::StubBuilder::Part.new(
          status:           500,
          headers:          { "response_header_name" => "response header value #{@unique_value}" },
          body:             "body #{@unique_value}",
          delay_in_seconds: 8,
          blocks:           []
        )
        @triggers = {
          scenarios: [],
          stubs:     []
        }
      end

      def match_rules=(options)
        self.tap { @match_rules.hash = options }
      end

      def response=(options)
        self.tap { @response.hash = options }
      end

      def with_response!(options)
        self.tap { @response.merge!(options) }
      end

      def with_response_block!
        block = lambda do |request|
          { headers: { header_name: "header value #{request.headers[:some_header]}" } }
        end
        with_response!(blocks: [ block ])
      end

      def with_text_response!
        with_response!(body: "payload #{@unique_value} text response")
      end

      def with_file_response!
        with_response!(body: { file: { path: "payload/#{@unique_value}/file.path",
                                       name: "payload_#{@unique_value}_file.name" } })
      end

      def with_triggered_scenarios!(scenario_names=[ "scenario name", "another scenario name" ])
        self.tap { @triggers[:scenarios].concat(scenario_names) }
      end

      def with_triggered_stubs!(stubs=[ HttpStub::Configurator::Stub.create, HttpStub::Configurator::Stub.create ])
        self.tap { @triggers[:stubs].concat(stubs) }
      end

      def build_hash
        build.to_hash
      end

      def build
        HttpStub::Configurator::Stub.create do |stub|
          stub.match_requests(@match_rules.to_hash)
          stub.respond_with(@response.to_hash)
          stub.trigger(@triggers)
        end
      end

    end

  end
end
