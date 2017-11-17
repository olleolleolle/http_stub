module HttpStub
  module Server
    module Stub
      module Response

        class Blocks

          delegate :each, to: :@blocks

          def initialize(blocks)
            @blocks = blocks || []
          end

          def evaluate_with(request)
            @blocks.reduce({}) { |result, block| result.deep_merge(call_block(block, request)) }
          end

          def to_array
            @blocks.map(&:source)
          end

          private

          def call_block(block, request)
            block.arity.zero? ? block.call : block.call(request)
          end

        end

      end
    end
  end
end
