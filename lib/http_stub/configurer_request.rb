module HttpStub

  class ConfigurerRequest

    def initialize(host, port, request, description)
      @host = host
      @port = port
      @request = request
      @description = description
    end

    def submit
      response = Net::HTTP.new(@host, @port).start { |http| http.request(@request) }
      raise "Error occurred #{@description}: #{response.message}" unless response.code == "200"
    end

  end
end
