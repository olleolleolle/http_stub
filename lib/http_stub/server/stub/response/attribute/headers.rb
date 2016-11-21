module HttpStub
  module Server
    module Stub
      module Response
        module Attribute

          class Headers < ::Hash
            include HttpStub::Extensions::Core::Hash::Formatted

            def initialize(stub_headers)
              super(stub_headers, ":")
            end

            def with_values_from(request)
              self.each_with_object({}) do |(name, value), result|
                result[name] = value.is_a?(String) ? interpolate(value, request) : value
              end
            end

            private

            def interpolate(value, request)
              HttpStub::Server::Stub::Response::Attribute::Interpolator.interpolate(value, request)
            end

          end

        end
      end
    end
  end
end
