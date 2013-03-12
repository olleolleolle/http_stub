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
        handle(request, "registering activator '#{activation_uri}'")
      end

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
        handle(request, "stubbing '#{uri}'")
      end

      alias_method :stub_response!, :stub!

      def activate!(uri)
        handle(Net::HTTP::Get.new(uri), "activating '#{uri}'")
      end

      alias_method :activate_stub!, :activate!

      def initialize!
        pending_requests.each { |request| request.submit() }
        @initialized = true
      end

      def clear_activators!
        handle(Net::HTTP::Delete.new("/stubs/activators"), "clearing activators")
      end

      def clear!
        handle(Net::HTTP::Delete.new("/stubs"), "clearing stubs")
      end

      alias_method :clear_stubs!, :clear!

      private

      def handle(http_request, description)
        request = HttpStub::ConfigurerRequest.new(@host, @port, http_request, description)
        initialized? ? request.submit() : pending_requests << request
      end

      def pending_requests
        @activator_requests ||= []
      end

      def initialized?
        @initialized ||= false
      end

    end

    module InstanceMethods

      DELEGATE_METHODS = %w{ stub_activator stub! stub_response! activate! activate_stub! clear_activators! clear! clear_stubs! }

      def self.included(mod)
        DELEGATE_METHODS.each do |method_name|
          mod.class_eval <<-METHOD_DEF
            def #{method_name}(*args)
              self.class.#{method_name}(*args)
            end
          METHOD_DEF
        end
      end

    end

  end

end
