module HttpStub
  module Extensions
    module Rack
      module Handler

        def self.included(mod)
          mod.extend(ClassMethods)
        end

        module ClassMethods

          def self.extended(mod)
            mod.singleton_class.alias_method_chain :get, :run_check
          end

          def get_with_run_check(server)
            handler = get_without_run_check(server)
            raise NameError.new("#{server} Rack handler is invalid") unless handler.respond_to?(:run)
            handler
          end

        end

      end

    end
  end
end

::Rack::Handler.send(:include, ::HttpStub::Extensions::Rack::Handler)
