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

      def stub_alias(alias_uri, stub_uri, options)
        response_options = options[:response]
        request = Net::HTTP::Post.new("/stubs/aliases")
        request.content_type = "application/json"
        request.body = {
            "alias_uri" => alias_uri,
            "uri" => stub_uri,
            "method" => options[:method],
            "parameters" => options[:parameters] || {},
            "response" => {
                "status" => response_options[:status] || "200",
                "body" => response_options[:body]
            }
        }.to_json
        response = submit(request)
        raise "Unable to establish stub alias: #{response.message}" unless response.code == "200"
      end

      def submit(request)
        Net::HTTP.new(@host, @port).start { |http| http.request(request) }
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

      def clear!
        request = Net::HTTP::Delete.new("/stubs")
        response = self.class.submit(request)
        raise "Unable to clear stubs: #{response.message}" unless response.code == "200"
      end

    end

  end

end
