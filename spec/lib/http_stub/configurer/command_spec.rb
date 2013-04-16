describe HttpStub::Configurer::Command do

  let(:options) do
    { host: "some_host", port: 8888, request: double("HttpRequest"), description: "Some Description" }
  end

  let(:command) { HttpStub::Configurer::Command.new(resetable: true) }

  describe "#resetable" do

    describe "when created with a resetable flag that is true" do

      let(:options) { options.merge(resetable: true) }

      it "should return true" do
        command.should be_resetable
      end

    end

    describe "when created without a resetable flag" do

      it "should return false" do
        command.should be_resetable
      end

    end

  end

end
