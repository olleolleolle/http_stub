module HttpStub
  module Configurer
    module Request

      class Regexpable

        class << self

          FORMATTERS = { Regexp => :format_regexp, Hash => :format_hash }.freeze

          private_constant :FORMATTERS

          def format(value)
            formatter = FORMATTERS.find { |formatter_entry| value.is_a?(formatter_entry[0]) }
            formatter ? self.send(formatter[1], value) : value
          end

          private

          def format_regexp(regexp)
            "regexp:#{regexp.source.gsub(%r{\\\/}, "/")}"
          end

          def format_hash(hash)
            hash.each_with_object({}) { |entry, result| result[entry[0]] = format(entry[1]) }
          end

        end

      end
    end
  end
end
