module HttpStub
  module Configurer

    module Part

      def configure(configurer)
        @configurer = configurer
        configure_methods = self.methods.find_all { |method| method.to_s =~ /^configure_.+_(stub|scenario)s?$/ }
        configure_methods.each { |configure_method| self.send(configure_method) }
      end

      def method_missing(name, *args, &block)
        @configurer.send(name, *args, &block)
      end

    end

  end
end
