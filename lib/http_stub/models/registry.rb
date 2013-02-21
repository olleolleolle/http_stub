module HttpStub
  module Models

    class Registry

      def initialize(model_name)
        @model_name = model_name
        @models = []
      end

      def add(model, request)
        @models.unshift(model)
        request.logger.info "Registered #{@model_name}: #{model}"
      end

      def find_for(request)
        request.logger.info "Finding #{@model_name} satisfying: #{request.inspect}"
        @models.find { |model| model.satisfies?(request) }
      end

      def clear(request)
        request.logger.info "Clearing #{@model_name} registry"
        @models.clear
      end

    end

  end
end
