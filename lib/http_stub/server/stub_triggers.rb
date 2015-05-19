module HttpStub
  module Server

    class StubTriggers

      delegate :each, to: :@triggers

      def initialize(triggers)
        @triggers = (triggers || []).map { |trigger| HttpStub::Server::Stub.new(trigger) }
      end

      def add_to(registry, request)
        @triggers.each { |trigger| registry.add(trigger, request) }
      end

      def clear
        @triggers.each(&:clear)
      end

      def to_s
        @triggers.reduce("") { |result, trigger| "#{result}\n#{trigger}" }
      end

    end

  end
end
