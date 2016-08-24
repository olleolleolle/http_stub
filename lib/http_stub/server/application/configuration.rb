module HttpStub
  module Server
    module Application

      class Configuration

        def initialize(args)
          @configurer = args[:configurer]
          @port       = args[:port]
        end

        def settings
          @configurer ? configurer_settings : direct_settings
        end

        private

        def configurer_settings
          {
            port:                 @configurer.stub_server.port,
            session_identifier:   @configurer.stub_server.session_identifier,
            cross_origin_support: @configurer.stub_server.enabled?(:cross_origin_support)
          }
        end

        def direct_settings
          {
            port:                 @port,
            session_identifier:   nil,
            cross_origin_support: false
          }
        end

      end

    end
  end
end
