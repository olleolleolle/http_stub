shared_context "server integration" do

  FIVE_SECONDS = 5

  before(:all) do
    @pid = Process.spawn("rake start_example_server --trace")
    wait_until("http stub server started") { Net::HTTP.get_response("localhost", "/", 8001) }
  end

  after(:all) do
    Process.kill(9, @pid)
  end

  def wait_until(description, &block)
    start_time = Time.now
    while true
      begin
        block.call
        return
      rescue
        if Time.now - start_time > FIVE_SECONDS
          raise "Timed out waiting until #{description}"
        end
      end
    end
  end

end
