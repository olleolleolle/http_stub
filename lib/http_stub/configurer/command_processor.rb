module HttpStub
  module Configurer

    class CommandProcessor

      def initialize(configurer)
        @configurer = configurer
      end

      def process(command)
        response = Net::HTTP.start(@configurer.get_host, @configurer.get_port) { |http| http.request(command.request) }
        raise "Error occurred #{command.description}: #{response.message}" unless response.code == "200"
      end

    end

  end
end
