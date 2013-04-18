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
        request = HttpStub::Configurer::Request::StubActivator.new(activation_uri, stub_uri, options)
        handle(request: request, description: "registering activator '#{activation_uri}'")
      end

      def stub!(uri, options)
        request = HttpStub::Configurer::Request::Stub.new(uri, options)
        handle(request: request, description: "stubbing '#{uri}'", resetable: true)
      end

      alias_method :stub_response!, :stub!

      def activate!(uri)
        handle(request: Net::HTTP::Get.new(uri), description: "activating '#{uri}'", resetable: true)
      end

      alias_method :activate_stub!, :activate!

      def server_has_started!
        @effective_command_chain = HttpStub::Configurer::ImpatientCommandChain.new()
      end

      def initialize!
        server_has_started!
        initialize_command_chain.execute()
      end

      def reset!
        clear!
        initialize_command_chain.filter(&:resetable?).execute()
      end

      def clear_activators!
        handle(request: Net::HTTP::Delete.new("/stubs/activators"), description: "clearing activators")
      end

      def clear!
        handle(request: Net::HTTP::Delete.new("/stubs"), description: "clearing stubs")
      end

      alias_method :clear_stubs!, :clear!

      private

      def handle(command_options)
        effective_command_chain <<
            HttpStub::Configurer::Command.new({ host: @host, port: @port }.merge(command_options))
      end

      def effective_command_chain
        @effective_command_chain ||= initialize_command_chain
      end

      def initialize_command_chain
        @initialize_command_chain ||= HttpStub::Configurer::PatientCommandChain.new()
      end

    end

    module InstanceMethods

      DELEGATE_METHODS = %w{ stub_activator stub! stub_response! activate! activate_stub!
                             server_has_started! reset! clear_activators! clear! clear_stubs! }

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
