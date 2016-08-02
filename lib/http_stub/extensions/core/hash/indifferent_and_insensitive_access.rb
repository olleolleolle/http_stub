module HttpStub
  module Extensions
    module Core
      module Hash

        module IndifferentAndInsensitiveAccess

          def [](key)
            self.key?(key) ? super : indifferent_and_insensitive_find(key)
          end

          private

          def indifferent_and_insensitive_find(key)
            entry = self.find { |entry_key, _entry_value| entry_key.to_s.casecmp(key.to_s).zero? }
            entry ? entry[1] : nil
          end

        end

      end
    end
  end
end
