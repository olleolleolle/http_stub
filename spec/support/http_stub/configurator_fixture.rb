module HttpStub

  class ConfiguratorFixture

    def self.create(args={})
      Class.new.tap do |configurator|
        configurator.send(:include, HttpStub::Configurator)
        configurator.stub_server.port = args[:port] || HttpStub::Port.free_port
      end
    end

  end
end
