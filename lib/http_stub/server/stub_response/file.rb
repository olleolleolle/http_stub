module HttpStub
  module Server
    module StubResponse

      class File < HttpStub::Server::StubResponse::Base

        add_default_headers "content-type" => "application/octet-stream"

        def initialize(args)
          @file_path = args["body"][:tempfile].path
          super(args.merge("body" => @file_path))
        end

        def serve_on(server)
          server.send_file(@file_path, send_options)
        end

        private

        def send_options
          { status: @status, type: @headers["content-type"] }.tap do |options|
            options[:last_modified] = @headers["last-modified"]       if @headers["last-modified"]
            options[:disposition]   = @headers["content-disposition"] if @headers["content-disposition"]
          end
        end

      end

    end
  end
end
