shared_context "server integration" do

  before(:all) do
    @pid = Process.spawn("rake start_example_server --trace")
    ::Wait.until!("http stub server started") { Net::HTTP.get_response("localhost", "/", 8001) }
  end

  after(:all) do
    Process.kill(9, @pid)
  end

end
