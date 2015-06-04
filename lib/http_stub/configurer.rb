module HttpStub

  module Configurer

    def self.included(mod)
      mod.extend(HttpStub::Configurer::ClassMethods)
      mod.send(:include, HttpStub::Configurer::InstanceMethods)
      mod.send(:include, HttpStub::Configurer::DSL::Deprecated)
    end

    module ClassMethods

      def get_host
        @host
      end

      def host(host)
        @host = host
      end

      def get_port
        @port
      end

      def port(port)
        @port = port
      end

      def get_base_uri
        "http://#{@host}:#{@port}"
      end

      def stub_server
        @dsl ||= HttpStub::Configurer::DSL::Sanctioned.new(server_facade)
      end

      def initialize!
        on_initialize if self.respond_to?(:on_initialize) && !@initialized
        server_facade.flush_requests
        server_facade.remember_stubs
        @initialized = true
      end

      private

      def server_facade
        @server_facade ||= HttpStub::Configurer::Server::Facade.new(self)
      end

    end

    module InstanceMethods

      def stub_server
        self.class.stub_server
      end

    end

  end

end
