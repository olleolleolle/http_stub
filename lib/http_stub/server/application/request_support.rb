module HttpStub
  module Server
    module Application

      module RequestSupport

        STUBBABLE_REQUEST_METHODS = [ :get, :post, :put, :patch, :delete, :options ].freeze

        private_constant :STUBBABLE_REQUEST_METHODS

        attr_reader :http_stub_request

        def initialize
          super()
          @request_factory = HttpStub::Server::Request::Factory.new(@session_configuration, @server_memory)
        end

        def establish_http_stub_request
          @http_stub_request = @request_factory.create(request, params, logger)
        end

        def self.included(application)
          application.instance_eval do

            def self.any_request_method(path, opts={}, &block)
              STUBBABLE_REQUEST_METHODS.each { |request_method| self.send(request_method, path, opts, &block) }
            end

            before { establish_http_stub_request }

          end
        end

      end

    end
  end
end
