module HttpStub
  module Extensions

    module Random

      def self.included(mod)
        mod.extend(ClassMethods)
      end

      module ClassMethods

        def string
          "string #{rand(100_000)}"
        end

      end

    end

  end
end

::Random.send(:include, HttpStub::Extensions::Random)
