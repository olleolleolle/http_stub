module HttpStub
  module Server
    module Stub
      module Response
        module Attribute
          module Interpolator

            class Headers

              CONTROL_VALUE_REGEXP = /control:request\.headers\[([^\]]+)\]/

              private_constant :CONTROL_VALUE_REGEXP

              def self.interpolate(stub_headers, request)
                stub_headers.scan(CONTROL_VALUE_REGEXP).flatten.reduce(stub_headers) do |result, header_name|
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
