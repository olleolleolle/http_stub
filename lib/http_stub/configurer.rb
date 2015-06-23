module HttpStub

  module Configurer

    def self.included(mod)
      mod.extend(HttpStub::Configurer::ClassMethods)
      mod.send(:include, HttpStub::Configurer::InstanceMethods)
      mod.send(:include, HttpStub::Configurer::DSL::Deprecated)
    end

    module ClassMethods

      def stub_server
        @stub_server ||= HttpStub::Configurer::DSL::Server.new(server_facade)
      end

      def initialize!
        on_initialize if self.respond_to?(:on_initialize) && !@initialized
        server_facade.flush_requests
        server_facade.remember_stubs
        @initialized = true
      end

      def parts=(parts)
        parts.each do |name, part|
          part.configure
          self.define_singleton_method(name) { part }
          self.send(:define_method, name) { part }
        end
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
