describe HttpStub::Configurer do

  class TestableConfigurer
    include HttpStub::Configurer

    host "some_host"
    port "8888"
  end

  describe "::get_base_uri" do

    it "returns a uri that combines the provided host and port" do
      expect(TestableConfigurer.get_base_uri).to include("some_host:8888")
    end

    it "returns a uri accessed via http" do
      expect(TestableConfigurer.get_base_uri).to match(/^http:\/\//)
    end

  end

end
