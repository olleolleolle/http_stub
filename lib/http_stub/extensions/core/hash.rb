module HttpStub
  module Extensions
    module Core

      module Hash

        def underscore_keys
          self.each_with_object({}) do |element, result|
            result[element[0].is_a?(::String) ? element[0].tr("-", "_") : element[0]] = element[1]
          end
        end

        def with_indifferent_and_insensitive_access
          HttpStub::Extensions::Core::Hash::WithIndifferentAndInsensitiveAccess.new(self)
        end

      end

    end
  end
end

::Hash.send(:include, HttpStub::Extensions::Core::Hash)
