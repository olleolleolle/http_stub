module HttpStub

  class Port

    def self.free_port
      tcp_server = TCPServer.new(@host, 0)
      tcp_server.local_address.ip_port.tap { tcp_server.close }
    end

  end

end
