module HttpStub
  module Server
    module Application

      class Application < Sinatra::Base

        register Sinatra::Namespace
        register Sinatra::Partial

        set :root, File.expand_path("..", __dir__)
        set :environment, :test
        set :session_identifier, nil

        enable  :dump_errors, :logging, :partial_underscores
        disable :protection, :cross_origin_support

        class << self

          attr_reader :configurator_state

          def configure(configurator)
            @configurator_state = configurator.state
            @configurator_state.application_settings.each { |name, value| set(name, value) }
          end

        end

        def initialize
          @server_memory = HttpStub::Server::Memory::Memory.new(self.class.configurator_state)
          super()
        end

        include HttpStub::Server::Application::RequestSupport

        register HttpStub::Server::Application::CrossOriginSupport

        include HttpStub::Server::Application::Routes::Resource
        include HttpStub::Server::Application::Routes::Status
        include HttpStub::Server::Application::Routes::Memory
        include HttpStub::Server::Application::Routes::Scenario
        include HttpStub::Server::Application::Routes::Session
        include HttpStub::Server::Application::Routes::Stub

        helpers HttpStub::Server::Application::SessionUriSupport
        helpers HttpStub::Server::Application::TextFormattingSupport

      end

    end
  end
end
