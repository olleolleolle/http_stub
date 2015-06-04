module HttpStub
  module Configurer
    module DSL

      module ScenarioActivator

        def activate!(*uri)
          activate_all!(uri.flatten)
        end

      end

    end
  end
end
