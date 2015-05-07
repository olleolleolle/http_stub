module HttpStub
  module Configurer
    module Server

      class CommandProcessor

        def initialize(configurer)
          @configurer = configurer
        end

        def process(command)
          begin
            response = Net::HTTP.start(host, port) { |http| http.request(command.http_request) }
            raise "#{error_message_prefix(command)}: #{response.code} #{response.message}" unless response.code == "200"
          rescue Exception => exc
            raise "#{error_message_prefix(command)}: #{exc}"
          end
        end

        private

        def host
          @configurer.get_host
        end

        def port
          @configurer.get_port
        end

        def error_message_prefix(command)
          "Error occurred #{command.description} whilst configuring #{@configurer.get_base_uri}: "
        end

      end

    end
  end
end
