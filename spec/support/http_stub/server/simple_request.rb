module HttpStub
  module Server

    class SimpleRequest

      attr_reader :headers, :parameters

      def initialize(args)
        resolved_args = { headers: {}, parameters: {} }.with_indifferent_access.merge(args)
        @headers    = resolved_args[:headers]
        @parameters = resolved_args[:parameters]
      end

    end

  end
end
