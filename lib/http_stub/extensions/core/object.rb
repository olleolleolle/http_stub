module HttpStub
  module Extensions
    module Core

      module Object

        def short_class_name
          self.class.name.demodulize.underscore
        end

      end

    end
  end
end

::Object.send(:include, HttpStub::Extensions::Core::Object)
