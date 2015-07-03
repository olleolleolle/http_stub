module HttpStub
  module Server
    module Stub

      class Triggers

        delegate :each, to: :@triggers

        def initialize(triggers)
          @triggers = (triggers || []).map { |trigger| HttpStub::Server::Stub.create(trigger) }
        end

        def add_to(registry, logger)
          @triggers.each { |trigger| registry.add(trigger, logger) }
        end

        def to_s
          @triggers.reduce("") { |result, trigger| "#{result}\n#{trigger}" }
        end

      end

    end
  end
end
