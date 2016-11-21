module HttpStub
  module Server
    module Stub
      module Response
        module Attribute
          module Interpolator

            class Parameters

              CONTROL_VALUE_REGEXP = /control:request\.parameters\[([^\]]+)\]/

              private_constant :CONTROL_VALUE_REGEXP

              def self.interpolate(value, request)
                value.scan(CONTROL_VALUE_REGEXP).flatten.reduce(value) do |result, parameter_name|
                  result.gsub("control:request.parameters[#{parameter_name}]", request.parameters[parameter_name] || "")
                end
              end

            end

          end
        end
      end
    end
  end
end
