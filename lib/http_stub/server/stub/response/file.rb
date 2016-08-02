module HttpStub
  module Server
    module Stub
      module Response

        class File < HttpStub::Server::Stub::Response::Base

          add_default_headers "content-type" => "application/octet-stream"

          attr_reader :uri

          def initialize(args)
            @file = args["body"][:tempfile]
            @uri  = "file://#{@file.path}"
            super
          end

          def with_values_from(request)
            self.class.new(@original_args.merge("headers" => @headers.with_values_from(request)))
          end

          def serve_on(application)
            application.send_file(@file.path, send_options)
          end

          private

          def send_options
            { type: @headers["content-type"] }.tap do |options|
              options[:last_modified] = @headers["last-modified"]       if @headers["last-modified"]
              options[:disposition]   = @headers["content-disposition"] if @headers["content-disposition"]
            end
          end

        end

      end
    end
  end
end
