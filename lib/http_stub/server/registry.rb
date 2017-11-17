module HttpStub
  module Server

    class Registry

      delegate :find_all, to: :@models

      def initialize(model_name, models=[])
        @model_name = model_name
        @models     = models.reverse
      end

      def add(model, logger)
        @models.unshift(model)
        log_addition_of([ model ], logger)
      end

      def concat(models, logger)
        @models.unshift(*models.reverse)
        log_addition_of(models.reverse, logger)
      end

      def replace(models, logger)
        log_pending_clear(logger)
        @models.replace(models.reverse)
        log_addition_of(models.reverse, logger)
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

      def delete(criteria, logger)
        logger.info "Deleting #{@model_name} matching: #{criteria}"
        @models.delete_if { |model| model.matches?(criteria, logger) }
      end

      def clear(logger)
        log_pending_clear(logger)
        @models.clear
      end

      private

      def log_pending_clear(logger)
        logger.info "Clearing #{@model_name} registry"
      end

      def log_addition_of(models, logger)
        models.each { |model| logger.info "Registered #{@model_name}: #{model}" }
      end

    end

  end
end
