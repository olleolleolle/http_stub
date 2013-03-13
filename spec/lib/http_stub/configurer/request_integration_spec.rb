describe HttpStub::Configurer::Request, "when the server is running" do
  include_context "server integration"

  let(:configurer_request) { HttpStub::Configurer::Request.new("localhost", 8001, request, "performing an operation") }

  describe "#submit" do

    describe "when the server responds with a 200 response" do

      let(:request) { Net::HTTP::Get.new("/stubs") }

      it "should execute without error" do
        lambda { configurer_request.submit() }.should_not raise_error
      end

    end

    describe "when the server responds with a non-200 response" do

      let(:request) { Net::HTTP::Get.new("/causes_error") }

      it "should raise an exception that includes the description" do
        lambda { configurer_request.submit() }.should raise_error(/performing an operation/)
      end

    end

  end

end
