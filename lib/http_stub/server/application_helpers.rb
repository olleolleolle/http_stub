module HttpStub
  module Server

    module ApplicationHelpers

      def h(text)
        Rack::Utils.escape_html(text)
      end

      def pp(text)
        begin
          text ? JSON.pretty_generate(JSON.parse(text)) : ""
        rescue JSON::ParserError
          text
        end
      end

    end

  end
end
