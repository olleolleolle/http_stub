module HttpStub
  module Models
    module StubResponse

      class File < HttpStub::Models::StubResponse::Base

        private

        STORAGE_DIR = "#{HttpStub::BASE_DIR}/tmp/response_files".freeze

        public

        add_default_headers "content-type" => "application/octet-stream"

        def initialize(args)
          @file_path = store_file(args["body"])
          super(args.merge("body" => @file_path))
        end

        def serve_on(server)
          server.send_file(@file_path, send_options)
        end

        def clear
          FileUtils.rm_f(@file_path)
        end

        private

        def store_file(upload)
          FileUtils.mkdir_p(STORAGE_DIR)
          "#{STORAGE_DIR}/#{upload[:filename]}".tap do |file_path|
            ::File.open(file_path, "w") { |file| file.write(upload[:tempfile].read) }
          end
        end

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
