module HttpStub
  module Server

    class FormattedHash < Hash

      def initialize(hash, key_value_delimiter)
        self.merge!(hash || {})
        @key_value_delimiter = key_value_delimiter
      end

      def to_s
        self.map { |key_and_value| key_and_value.map(&:to_s).join(@key_value_delimiter) }.join(", ")
      end

    end

  end
end
