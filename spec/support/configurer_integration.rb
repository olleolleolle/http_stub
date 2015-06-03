shared_context "configurer integration" do
  include_context "server integration"

  let(:stub_server) { configurer.stub_server }

  before(:example) do
    configurer.class.host(server_host)
    configurer.class.port(server_port)
  end

  after(:example) do
    stub_server.clear_stubs!
    stub_server.clear_scenarios!
  end

  def expect_response_to_contain_file(path)
    response_file = Tempfile.new(File.basename(path)).tap do |file|
      file.write(response.parsed_response)
      file.flush
    end
    expect(FileUtils.compare_file(path, response_file.path)).to be(true)
  end

end
