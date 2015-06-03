module HttpStub

  class ScenarioFixture

    def initialize
      @activation_uri = "/some/activation/uri"
      @stub_fixtures  = []
    end

    def with_activation_uri!(uri)
      self.tap { @activation_uri = uri }
    end

    def with_stubs!(number)
      self.tap { @stub_fixtures.concat((1..number).map { HttpStub::StubFixture.new }) }
    end

    def server_payload
      {
        "activation_uri"  => @activation_uri,
        "stubs" => @stub_fixtures.map(&:server_payload)
      }
    end

  end

end
