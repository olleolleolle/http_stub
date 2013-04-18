module HttpStub
  module Configurer
    module Request

      class Regexpable

        class << self

          private

          FORMATTERS = { String => :format_string, Regexp => :format_regexp, Hash => :format_hash }

          public

          def format(value)
            formatter = FORMATTERS.find { |formatter_entry| value.is_a?(formatter_entry[0]) }
            raise "No Regexp formatter found for #{value}" unless formatter
            self.send(formatter[1], value)
          end

          private

          def format_string(string)
            string
          end

          def format_regexp(regexp)
            "regexp:#{regexp.source.gsub(/\\/, "")}"
          end

          def format_hash(hash)
            hash.reduce({}) do |result, entry|
              result[entry[0]] = format(entry[1])
              result
            end
          end

        end

      end
    end
  end
end
