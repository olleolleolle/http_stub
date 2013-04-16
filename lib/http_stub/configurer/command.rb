module HttpStub
  module Configurer

    class Command

      def initialize(options)
        @host = options[:host]
        @port = options[:port]
        @request = options[:request]
        @description = options[:description]
        @resetable_flag = !!options[:resetable]
      end

      def execute
        response = Net::HTTP.start(@host, @port) { |http| http.request(@request) }
        raise "Error occurred #{@description}: #{response.message}" unless response.code == "200"
      end

      def resetable?
        @resetable_flag
      end

    end

  end
end
