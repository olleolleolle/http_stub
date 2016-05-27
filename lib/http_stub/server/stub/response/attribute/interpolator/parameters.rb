module HttpStub
  module Server
    module Stub
      module Response
        module Attribute
          module Interpolator

            class Parameters

              CONTROL_VALUE_REGEXP = /control:request\.params\[([^\]]+)\]/

              private_constant :CONTROL_VALUE_REGEXP

              def self.interpolate(stub_parameters, request)
                stub_parameters.scan(CONTROL_VALUE_REGEXP).flatten.reduce(stub_parameters) do |result, parameter_name|
                  result.gsub("control:request.params[#{parameter_name}]", request.parameters[parameter_name] || "")
                end
              end

            end

          end
        end
      end
    end
  end
end
