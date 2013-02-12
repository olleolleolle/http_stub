describe Http::Stub::StartServerRakeTask do
  include_context "server integration"

  describe("when the generated task is invoked") do

    it "should start a stub server that responds to stub requests" do
      request = Net::HTTP::Post.new("/stub")
      request.body = { "response" => { "status" => 302, "body" => "Some Body" } }.to_json

      response = Net::HTTP.new("localhost", 8001).start { |http| http.request(request) }

      response.code.should eql("200")
    end

  end

end
