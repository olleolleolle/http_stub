module HttpStub
  module Server
    module Application
      module Routes

        module Status

          def self.included(application)
            application.instance_eval do

              namespace "/http_stub/status" do

                get do
                  halt 200, "OK"
                end

              end

            end
          end

        end

      end
    end
  end
end
