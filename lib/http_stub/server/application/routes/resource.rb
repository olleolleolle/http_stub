module HttpStub
  module Server
    module Application
      module Routes

        module Resource

          def self.included(application)
            application.instance_eval do

              get "/application.css" do
                sass :application
              end

            end
          end

        end

      end
    end
  end
end
