module HttpStub
  module Server
    module Stub
      module Response

        class FileBody

          DEFAULT_HEADERS = { "content-type" => "application/octet-stream" }.freeze

          private_constant :DEFAULT_HEADERS

          attr_reader :uri

          def initialize(hash)
            @path = hash.dig(:file, :path)
            @uri  = "file://#{@path}"
          end

          def headers
            DEFAULT_HEADERS
          end

          def serve(application, response)
            application.send_file(@path, send_options(response))
          end

          def to_s
            @uri
          end

          private

          def send_options(response)
            headers = response.headers
            { type: headers["content-type"] }.tap do |options|
              options[:last_modified] = headers["last-modified"]       if headers["last-modified"]
              options[:disposition]   = headers["content-disposition"] if headers["content-disposition"]
            end
          end

        end

      end
    end
  end
end
