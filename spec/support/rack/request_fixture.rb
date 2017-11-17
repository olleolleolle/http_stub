module Rack

  class RequestFixture

    class << self

      def create(args={})
        Rack::Request.new(
          env_headers_for(args).merge(
            "PATH_INFO"      => "/some/path/info",
            "REQUEST_METHOD" => args[:method] || "GET",
            "QUERY_STRING"   => query_string_for(args),
            "rack.input"     => StringIO.new(args[:body] || ""))
        )
      end

      def env_headers_for(args)
        (args[:headers] || {}).each_with_object({}) do |(name, value), headers|
          headers["HTTP_#{name.to_s.upcase}"] = value
        end
      end

      def query_string_for(args)
        (args[:parameters] || []).map { |name, value| "#{name}=#{value}" }.join("&;")
      end

    end

  end

end
