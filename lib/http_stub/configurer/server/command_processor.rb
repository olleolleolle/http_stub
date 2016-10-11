module HttpStub
  module Configurer
    module Server

      class CommandProcessor

        def initialize(configuration)
          @configuration = configuration
        end

        def process(command, http_options={})
          response = send_command(command, http_options)
          raise "#{error_message_prefix(command)}: #{response.code} #{response.message}" unless response.code == "200"
          response
        rescue StandardError => err
          raise "#{error_message_prefix(command)}: #{err}"
        end

        private

        def send_command(command, http_options)
          Net::HTTP.start(@configuration.host, @configuration.port, http_options) do |http|
            http.request(command.http_request)
          end
        end

        def error_message_prefix(command)
          "Error occurred #{command.description} whilst configuring #{@configuration.base_uri}: "
        end

      end

    end
  end
end
