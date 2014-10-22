module HttpStub
  module Configurer

    module DeprecatedDSL

      def self.included(mod)
        mod.extend(HttpStub::Configurer::DeprecatedDSL::Methods)
        mod.send(:include, HttpStub::Configurer::DeprecatedDSL::Methods)
      end

      module Methods

        def server_has_started!
          stub_server.has_started!
        end

        def stub!(uri, options)
          stub_server.add_stub! { |stub| add_stub_options_to_builder(stub, uri, options) }
        end

        alias_method :stub_response!, :stub!

        def stub_activator(activation_uri, stub_uri, options)
          stub_server.add_activator! do |activator|
            activator.path(activation_uri)
            add_stub_options_to_builder(activator, stub_uri, options)
          end
        end

        def activate!(uri)
          stub_server.activate!(uri)
        end

        def recall_stubs!
          stub_server.recall_stubs!
        end

        def clear_stubs!
          stub_server.clear_stubs!
        end

        def clear_activators!
          stub_server.clear_activators!
        end

        private

        def add_stub_options_to_builder(stub, uri, options)
          stub.match_request(uri, options.slice(:method, :headers, :parameters))
          stub.respond_with(options[:response])
        end

      end

    end
  end
end
