module HttpStub
  module Server

    class Registry

      def initialize(model_name)
        @model_name = model_name
        @models     = []
      end

      def add(model, logger)
        @models.unshift(model)
        logger.info "Registered #{@model_name}: #{model}"
      end

      def concat(models, logger)
        models.each { |model| self.add(model, logger) }
      end

      def find(criteria, logger)
        logger.info "Finding #{@model_name} matching: #{criteria}"
        @models.find { |model| model.matches?(criteria, logger) }
      end

      def last
        @models.first
      end

      def all
        Array.new(@models)
      end

      def rollback_to(model)
        starting_index = @models.index(model)
        @models = @models.slice(starting_index..-1) if starting_index
      end

      def clear(logger)
        logger.info "Clearing #{@model_name} registry"
        @models.clear
      end

    end

  end
end
