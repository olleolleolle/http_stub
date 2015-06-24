module HttpStub
  module Configurer
    module DSL

      module Deprecated

        def self.included(mod)
          mod.extend(HttpStub::Configurer::DSL::Deprecated::Methods)
          mod.send(:include, HttpStub::Configurer::DSL::Deprecated::Methods)
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
              activator.on(activation_uri)
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
            stub_server.clear_scenarios!
          end

          private

          def add_stub_options_to_builder(stub, uri, options)
            stub.match_requests({ uri: uri }.merge(options.slice(:method, :headers, :parameters)))
            stub.respond_with(options[:response])
          end

        end

      end

    end
  end
end
