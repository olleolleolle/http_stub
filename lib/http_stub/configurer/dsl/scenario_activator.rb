module HttpStub
  module Configurer
    module DSL

      module ScenarioActivator

        def activate!(*names)
          activate_all!(names.flatten)
        end

      end

    end
  end
end
