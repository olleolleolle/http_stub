module HttpStub
  module Configurator

    class State

      attr_accessor :port

      attr_writer :session_identifier

      attr_reader :scenario_hashes, :stub_hashes

      def initialize
        @scenario_hashes           = []
        @stub_hashes               = []
        @cross_origin_support_flag = false
      end

      def external_base_uri
        ENV["STUB_EXTERNAL_BASE_URI"] || "http://localhost:#{@port}"
      end

      def enable(feature)
        @cross_origin_support_flag = true if feature == :cross_origin_support
      end

      def add_scenario(scenario)
        @scenario_hashes << scenario.to_hash
      end

      def add_stub(stub)
        @stub_hashes << stub.to_hash
      end

      def application_settings
        { port: @port, session_identifier: @session_identifier, cross_origin_support: @cross_origin_support_flag }
      end

    end

  end
end
