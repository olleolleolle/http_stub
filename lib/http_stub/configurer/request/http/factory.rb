module HttpStub
  module Configurer
    module Request
      module Http

        class Factory

          class << self

            def multipart(path, model, headers={})
              HttpStub::Configurer::Request::Http::Multipart.new(path: path, headers: headers, model: model)
            end

            def get(path, headers={})
              HttpStub::Configurer::Request::Http::Basic.new(method: :get, path: path, headers: headers)
            end

            def post(path, parameters={})
              HttpStub::Configurer::Request::Http::Basic.new(method: :post, path: path, parameters: parameters)
            end

            def delete(path, headers={})
              HttpStub::Configurer::Request::Http::Basic.new(method: :delete, path: path, headers: headers)
            end

          end

        end

      end
    end
  end
end
