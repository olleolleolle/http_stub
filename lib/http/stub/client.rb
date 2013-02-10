module Http
  module Stub
    module Client

      def self.included(mod)
        mod.extend(Http::Stub::Client::ClassMethods)
        mod.send(:include, Http::Stub::Client::InstanceMethods)
      end

      module ClassMethods

        attr_reader :host_value, :port_value

        def host(host)
          @host_value = host
        end

        def port(port)
          @port_value = port
        end

      end

      module InstanceMethods

        def stub_response!(uri, response_options)
          request = Net::HTTP::Post.new("/stub")
          request.content_type = "application/json"
          request.body = {
              "uri" => uri,
              "method" => response_options[:method],
              "response" => {
                  "status" => response_options[:status] || "200",
                  "body" => response_options[:body]
              }
          }.to_json
          response = Net::HTTP.new(self.class.host_value, self.class.port_value).start { |http| http.request(request) }
          raise "Unable to stub request, stub responded with: #{response.message}" unless response.code == "200"
        end

      end

    end
  end
end
