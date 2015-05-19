module HttpStub
  module Configurer
    module Request
      module Http

        class Factory

          class << self

            def stub(model)
              HttpStub::Configurer::Request::Http::Multipart.new("/stubs", model)
            end

            def stub_activator(model)
              HttpStub::Configurer::Request::Http::Multipart.new("/stubs/activators", model)
            end

            def get(path)
              to_basic_request(Net::HTTP::Get.new(path))
            end

            def post(path)
              to_basic_request(Net::HTTP::Post.new(path).tap { |request| request.body = "" })
            end

            def delete(path)
              to_basic_request(Net::HTTP::Delete.new(path))
            end

            private

            def to_basic_request(http_request)
              HttpStub::Configurer::Request::Http::Basic.new(http_request)
            end

          end

        end

      end
    end
  end
end
