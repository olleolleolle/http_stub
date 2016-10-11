module HttpStub
  module Configurer
    module Request
      module Http

        class Multipart

          def initialize(args)
            @model   = args[:model]
            @path    = args[:path]
            @headers = args[:headers] || {}
          end

          def to_http_request
            Net::HTTP::Post::Multipart.new("/http_stub/#{@path}", parameters, @headers.stringify_keys)
          end

          private

          def parameters
            { payload: @model.payload.to_json }.tap do |parameters|
              @model.response_files.each do |response_file|
                parameters["response_file_#{response_file.id}"] =
                  UploadIO.new(response_file.path, response_file.type, response_file.name)
              end
            end
          end

        end

      end
    end
  end
end
