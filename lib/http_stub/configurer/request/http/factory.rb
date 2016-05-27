module HttpStub
  module Configurer
    module Request
      module Http

        class Factory

          class << self

            def multipart(model)
              HttpStub::Configurer::Request::Http::Multipart.new(model)
            end

            def get(path)
              create_basic_request(:get, path.start_with?("/") ? path : "/#{path}")
            end

            def post(path, parameters={})
              create_basic_request(:post, path) { |http_request| http_request.set_form_data(parameters) }
            end

            def delete(path)
              create_basic_request(:delete, path)
            end

            private

            def create_basic_request(request_method, path, &_block)
              http_request_class = Net::HTTP.const_get(request_method.to_s.capitalize)
              http_request = http_request_class.new(path)
              yield http_request if block_given?
              HttpStub::Configurer::Request::Http::Basic.new(http_request)
            end

          end

        end

      end
    end
  end
end
