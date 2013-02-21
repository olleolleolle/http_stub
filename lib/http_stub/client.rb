module HttpStub

  module Client

    def self.included(mod)
      mod.extend(HttpStub::Client::ClassMethods)
      mod.send(:include, HttpStub::Client::InstanceMethods)
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

      def stub!(uri, options)
        response_options = options[:response]
        request = Net::HTTP::Post.new("/stub")
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
        response = submit(request)
        raise "Unable to stub request: #{response.message}" unless response.code == "200"
      end

      alias_method :stub_response!, :stub!

      def clear!
        request = Net::HTTP::Delete.new("/stubs")
        response = submit(request)
        raise "Unable to clear stubs: #{response.message}" unless response.code == "200"
      end

      private

      def submit(request)
        Net::HTTP.new(self.class.host_value, self.class.port_value).start { |http| http.request(request) }
      end

    end

  end

end
