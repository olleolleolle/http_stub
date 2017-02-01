module HttpStub
  module Extensions
    module Rack

      module Handler

        def self.prepended(mod)
          mod.singleton_class.prepend(ClassMethods)
        end

        module ClassMethods

          def get(server)
            handler = super
            raise NameError, "#{server} Rack handler is invalid" unless handler.respond_to?(:run)
            handler
          end

        end

      end

    end
  end
end

::Rack::Handler.prepend(::HttpStub::Extensions::Rack::Handler)
