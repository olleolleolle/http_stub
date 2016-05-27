module HttpStub
  module Server
    module Stub
      module Response
        module Attribute

          module Interpolator

            CHAIN = [
              HttpStub::Server::Stub::Response::Attribute::Interpolator::Headers,
              HttpStub::Server::Stub::Response::Attribute::Interpolator::Parameters
            ].freeze

            private_constant :CHAIN

            def self.interpolate(value, request)
              CHAIN.reduce(value) { |result, interpolator| interpolator.interpolate(result, request) }
            end

          end

        end
      end
    end
  end
end
