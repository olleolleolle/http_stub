describe HttpStub::Models::Parameters do

  let(:request_parameters) { double("RequestParameters") }
  let(:request) { double("HttpRequest", params: request_parameters) }

  let(:model_parameters) { { "key1" => "value1", "key2" => "value2", "key3" => "value3" } }
  let(:model) { HttpStub::Models::Parameters.new(model_parameters) }

  describe "#match?" do

    describe "when the request parameters contain the mandatory model parameters" do

      before(:each) { request_parameters.stub!(:has_hash?).with(model_parameters).and_return(true) }

      it "should return true" do
        model.match?(request).should be(true)
      end

    end

    describe "when the request parameters do not contain the mandatory model parameters" do

      before(:each) { request_parameters.stub!(:has_hash?).with(model_parameters).and_return(false) }

      it "should return false" do
        model.match?(request).should be(false)
      end

    end

  end

  describe "#to_s" do

    describe "when multiple parameters are provided" do

      let(:model_parameters) { { "key1" => "value1", "key2" => "value2", "key3" => "value3" } }

      it "should return a string containing each parameter formatted as a conventional request parameter" do
        result = model.to_s

        model_parameters.each { |key, value| result.should match(/#{key}=#{value}/) }
      end

      it "should separate each parameter with the conventional request parameter delimiter" do
        model.to_s.should match(/key\d.value\d\&key\d.value\d\&key\d.value\d/)
      end

    end

    describe "when empty parameters are provided" do

      let(:model_parameters) { {} }

      it "should return an empty string" do
        model.to_s.should eql("")
      end

    end

    describe "when nil parameters are provided" do

      let(:model_parameters) { nil }

      it "should return an empty string" do
        model.to_s.should eql("")
      end

    end

  end

end
