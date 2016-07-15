module HttpStub
  module Server
    module Application

      class ResponsePipeline

        def initialize(application)
          @application = application
        end

        def process(response)
          sleep response.delay_in_seconds
          response.serve_on(@application)
        end

      end

    end
  end
end
