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
        request = HttpStub::Configurer::StubActivatorRequest.new(activation_uri, stub_uri, options)
        handle(request, "registering activator '#{activation_uri}'")
      end

      def stub!(uri, options)
        request = HttpStub::Configurer::StubRequest.new(uri, options)
        handle(request, "stubbing '#{uri}'")
      end

      alias_method :stub_response!, :stub!

      def activate!(uri)
        handle(Net::HTTP::Get.new(uri), "activating '#{uri}'")
      end

      alias_method :activate_stub!, :activate!

      def initialize!
        processor.replay()
        @processor = HttpStub::Configurer::PostInitializeCommandProcessor.new(processor)
      end

      def clear_activators!
        handle(Net::HTTP::Delete.new("/stubs/activators"), "clearing activators")
      end

      def clear!
        handle(Net::HTTP::Delete.new("/stubs"), "clearing stubs")
      end

      alias_method :clear_stubs!, :clear!

      private

      def handle(request, description)
        processor.process(HttpStub::Configurer::Command.new(@host, @port, request, description))
      end

      def processor
        @processor ||= HttpStub::Configurer::PreInitializeCommandProcessor.new
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
