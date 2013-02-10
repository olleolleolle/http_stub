describe Http::Stub::RakeTask do
  include_context "server integration"

  describe("when the generated task is invoked") do

    it "should start a stub server that responds to stub requests" do
      request = Net::HTTP::Post.new("/stub")
      request.body = "{}"

      response = Net::HTTP.new("localhost", 8001).start { |http| http.request(request) }

      response.code.should eql("200")
    end

  end

end
