module HttpStub
  module Server
    module Stub
      module Response
        module Attribute
          module Interpolator

            class Headers

              CONTROL_VALUE_REGEXP = /control:request\.headers\[([^\]]+)\]/

              private_constant :CONTROL_VALUE_REGEXP

              def self.interpolate(value, request)
                value.scan(CONTROL_VALUE_REGEXP).flatten.reduce(value) do |result, header_name|
                  result.gsub("control:request.headers[#{header_name}]", request.headers[header_name] || "")
                end
              end

            end

          end
        end
      end
    end
  end
end
