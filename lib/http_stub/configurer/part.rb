module HttpStub
  module Configurer

    module Part

      def configure(configurer)
        @configurer = configurer
        configure_methods = self.methods.find_all { |method| method.to_s =~ /^configure_.+_(stub|scenario)s?$/ }
        configure_methods.each { |configure_method| self.send(configure_method) }
      end

      def method_missing(name, *args, &block)
        @configurer.respond_to?(name, true) ? @configurer.send(name, *args, &block) : super
      end

      def respond_to_missing?(name, include_private = false)
        @configurer.respond_to?(name, include_private)
      end

    end

  end
end
