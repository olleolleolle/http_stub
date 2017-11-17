module HttpStub
  module Configurator

    module Part

      def apply_to(configurator)
        @configurator = configurator
        configuration_methods = self.methods.find_all { |method| method.to_s =~ /^configure_.+_(stub|scenario)s?$/ }
        configuration_methods.each { |configuration_method| self.send(configuration_method) }
      end

      def method_missing(name, *args, &block)
        @configurator.respond_to?(name, true) ? @configurator.send(name, *args, &block) : super
      end

      def respond_to_missing?(name, include_private = false)
        @configurator.respond_to?(name, include_private)
      end

    end

  end
end
