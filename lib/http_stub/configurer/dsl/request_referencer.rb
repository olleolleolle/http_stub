module HttpStub
  module Configurer
    module DSL

      class RequestReferencer

        def initialize
          @parameter_referencer = HttpStub::Configurer::DSL::RequestAttributeReferencer.new(:parameters)
          @header_referencer    = HttpStub::Configurer::DSL::RequestAttributeReferencer.new(:headers)
        end

        def parameters
          @parameter_referencer
        end

        def headers
          @header_referencer
        end

      end

    end
  end
end
