module HttpStub
  module Server

    class Registry

      def initialize(model_name)
        @model_name = model_name
        @models = []
      end

      def add(model, request)
        @models.unshift(model)
        request.logger.info "Registered #{@model_name}: #{model}"
      end

      def concat(models, request)
        models.each { |model| self.add(model, request) }
      end

      def find(args)
        args[:request].logger.info "Finding #{@model_name} satisfying: #{args[:criteria]}"
        @models.find { |model| model.satisfies?(args[:criteria]) }
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

      def clear(request)
        request.logger.info "Clearing #{@model_name} registry"
        @models.clear
      end

    end

  end
end
