module HttpStub
  module Models

    class Headers < Hash

      def initialize(headers)
        self.merge!(headers || {})
      end

      def to_s
        self.map { |key_and_value| key_and_value.map(&:to_s).join(":") }.join(", ")
      end

    end

  end
end
