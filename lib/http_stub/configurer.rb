module HttpStub

  module Configurer

    def self.included(mod)
      mod.extend(HttpStub::Configurer::ClassMethods)
      mod.send(:include, HttpStub::Configurer::InstanceMethods)
    end

    module ClassMethods

      def host(host)
        @host = host
      end

      def port(port)
        @port = port
      end

      def stub_activator(activation_uri, stub_uri, options)
        response_options = options[:response]
        request = Net::HTTP::Post.new("/stubs/activators")
        request.content_type = "application/json"
        request.body = {
            "activation_uri" => activation_uri,
            "uri" => stub_uri,
            "method" => options[:method],
            "headers" => options[:headers] || {},
            "parameters" => options[:parameters] || {},
            "response" => {
                "status" => response_options[:status] || "200",
                "body" => response_options[:body]
            }
        }.to_json
        activator_requests << request
      end

      def initialize!
        activator_requests.each do |request|
          response = submit(request)
          raise "Unable to initialize stub activator: #{response.message}" unless response.code == "200"
        end
      end

      def clear_activators!
        request = Net::HTTP::Delete.new("/stubs/activators")
        response = submit(request)
        raise "Unable to clear stub activators: #{response.message}" unless response.code == "200"
      end

      def submit(request)
        Net::HTTP.new(@host, @port).start { |http| http.request(request) }
      end

      private

      def activator_requests
        @activator_requests ||= []
      end

    end

    module InstanceMethods

      def stub!(uri, options)
        response_options = options[:response]
        request = Net::HTTP::Post.new("/stubs")
        request.content_type = "application/json"
        request.body = {
            "uri" => uri,
            "method" => options[:method],
            "headers" => options[:headers] || {},
            "parameters" => options[:parameters] || {},
            "response" => {
                "status" => response_options[:status] || "200",
                "body" => response_options[:body]
            }
        }.to_json
        response = self.class.submit(request)
        raise "Unable to establish stub: #{response.message}" unless response.code == "200"
      end

      alias_method :stub_response!, :stub!

      def activate!(uri)
        request = Net::HTTP::Get.new(uri)
        response = self.class.submit(request)
        raise "Activator #{uri} not configured: #{response.message}" unless response.code == "200"
      end

      alias_method :activate_stub!, :activate!

      def clear!
        request = Net::HTTP::Delete.new("/stubs")
        response = self.class.submit(request)
        raise "Unable to clear stubs: #{response.message}" unless response.code == "200"
      end

    end

  end

end
