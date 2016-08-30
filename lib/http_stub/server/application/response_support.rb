module HttpStub
  module Server
    module Application

      module ResponseSupport

        def self.included(application)
          application.instance_eval do

            before { @response_pipeline = HttpStub::Server::Application::ResponsePipeline.new(self) }

          end
        end

      end

    end
  end
end
