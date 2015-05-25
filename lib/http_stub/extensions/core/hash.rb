module HttpStub
  module Extensions
    module Core

      module Hash

        def downcase_and_underscore_keys
          self.reduce({}) do |result, element|
            result[element[0].is_a?(::String) ? element[0].downcase.gsub(/-/, '_') : element[0]] = element[1]
            result
          end
        end

        def has_hash?(other_hash)
          other_hash.nil? || other_hash.reduce(true) do |result, element|
            result && (self[element[0]] == element[1])
          end
        end

        def with_indifferent_and_insensitive_access
          HttpStub::HashWithIndifferentAndInsensitiveAccess.new(self)
        end

      end

    end
  end
end

::Hash.send(:include, HttpStub::Extensions::Core::Hash)
