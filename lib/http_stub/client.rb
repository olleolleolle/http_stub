require 'net/http'

require_relative 'client/request'
require_relative 'client/server'
require_relative 'client/session'
require_relative 'client/client'

module HttpStub

  module Client

    def self.create(server_uri)
      HttpStub::Client::Client.new(server_uri)
    end

  end

end
