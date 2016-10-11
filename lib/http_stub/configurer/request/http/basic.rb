module HttpStub
  module Configurer
    module Request
      module Http

        class Basic

          def initialize(args)
            @request_method = args[:method]
            @path           = args[:path]
            @headers        = args[:headers] || {}
            @parameters     = args[:parameters]
          end

          def to_http_request
            http_request_class = Net::HTTP.const_get(@request_method.to_s.capitalize)
            http_request_class.new("/http_stub/#{@path}", @headers.stringify_keys).tap do |http_request|
              http_request.set_form_data(@parameters) if @parameters
            end
          end

        end

      end
    end
  end
end
