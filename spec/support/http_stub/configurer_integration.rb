shared_context "configurer integration" do
  include_context "server integration"

  let(:stub_registrator) { HttpStub::StubRegistrator.new(stub_server) }

  def configurer
    HttpStub::EmptyConfigurer
  end

  def stub_server
    configurer.stub_server
  end

end
