module HttpStub
  module Configurer
    module Server

      class Configuration

        attr_accessor :host, :port, :session_identifier

        def initialize
          @enabled_features = []
        end

        def base_uri
          "http://#{host}:#{port}"
        end

        def external_base_uri
          ENV["STUB_EXTERNAL_BASE_URI"] || base_uri
        end

        def enable(*features)
          @enabled_features = features
        end

        def enabled?(feature)
          @enabled_features.include?(feature)
        end

      end

    end
  end
end
