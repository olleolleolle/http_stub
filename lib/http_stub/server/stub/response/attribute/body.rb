module HttpStub
  module Server
    module Stub
      module Response
        module Attribute

          class Body < ::String

            def initialize(stub_body)
              @stub_body = stub_body
              super stub_body.nil? ? "" : stub_body
            end

            def with_values_from(request)
              if self.provided?
                HttpStub::Server::Stub::Response::Attribute::Interpolator.interpolate(@stub_body, request)
              else
                nil
              end
            end

            def provided?
              !@stub_body.nil?
            end

          end

        end
      end
    end
  end
end
