module HttpStub
  module Configurer
    module Server

      class CommandProcessor

        def initialize(configurer)
          @configurer = configurer
        end

        def process(command, http_options={})
          response = Net::HTTP.start(host, port, http_options) { |http| http.request(command.http_request) }
          raise "#{error_message_prefix(command)}: #{response.code} #{response.message}" unless response.code == "200"
          response
        rescue StandardError => err
          raise "#{error_message_prefix(command)}: #{err}"
        end

        private

        def host
          @configurer.stub_server.host
        end

        def port
          @configurer.stub_server.port
        end

        def error_message_prefix(command)
          "Error occurred #{command.description} whilst configuring #{@configurer.stub_server.base_uri}: "
        end

      end

    end
  end
end
