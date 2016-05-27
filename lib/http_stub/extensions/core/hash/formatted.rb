module HttpStub
  module Extensions
    module Core
      module Hash

        module Formatted

          def initialize(hash, key_value_delimiter, entry_delimiter=", ")
            self.merge!(hash || {})
            @key_value_delimiter = key_value_delimiter
            @entry_delimiter     = entry_delimiter
          end

          def to_s
            self.map { |key_and_value| key_and_value.map(&:to_s).join(@key_value_delimiter) }.join(@entry_delimiter)
          end

        end

      end
    end
  end
end
