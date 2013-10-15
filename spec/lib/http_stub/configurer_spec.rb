describe HttpStub::Configurer do

  class TestableConfigurer
    include HttpStub::Configurer

    host "some_host"
    port "8888"
  end

  describe ".get_base_uri" do

    it "should return a uri that combines the provided host and port" do
      TestableConfigurer.get_base_uri.should include("some_host:8888")
    end

    it "should return a uri accessed via http" do
      TestableConfigurer.get_base_uri.should match(/^http:\/\//)
    end

  end

end
