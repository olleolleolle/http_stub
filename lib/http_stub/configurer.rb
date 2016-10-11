module HttpStub

  module Configurer

    def self.included(mod)
      mod.extend(HttpStub::Configurer::ClassMethods)
      mod.send(:include, HttpStub::Configurer::InstanceMethods)
    end

    module ClassMethods

      def stub_server
        @stub_server ||= HttpStub::Configurer::DSL::Server.new
      end

      def initialize!
        on_initialize if self.respond_to?(:on_initialize) && !@initialized
        stub_server.initialize!
        @initialized = true
      end

      def parts=(parts)
        parts.each do |name, part|
          part.configure(self)
          self.define_singleton_method(name) { part }
          self.send(:define_method, name) { part }
        end
      end

    end

    module InstanceMethods

      def stub_server
        self.class.stub_server
      end

    end

  end

end
