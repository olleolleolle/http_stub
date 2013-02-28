describe HttpStub::Models::Parameters do

  let(:request) { double("HttpRequest", params: request_params) }

  let(:parameters) { HttpStub::Models::Parameters.new(params) }

  describe "#match?" do

    describe "when multiple parameters are provided" do

      let(:params) { { "key1" => "value1", "key2" => "value2", "key3" => "value3" } }

      describe "and the request contains only those parameters" do

        let(:request_params) { params }

        it "should return true" do
          parameters.match?(request).should be(true)
        end

      end

      describe "and the request contains more than those parameters" do

        let(:request_params) { params.merge("key4" => "value4") }

        it "should return true" do
          parameters.match?(request).should be(true)
        end

      end

      describe "and the requests contains only those parameters with values that do not match" do

        let(:request_params) { { "key1" => "value1", "key2" => "nonMatchingValue", "key3" => "value3" } }

        it "should return false" do
          parameters.match?(request).should be(false)
        end

      end

      describe "and the request contains a subset of those parameters" do

        let(:request_params) { { "key1" => "value1", "key3" => "value3" } }

        it "should return false" do
          parameters.match?(request).should be(false)
        end

      end

      describe "and the request contains no parameters" do

        let(:request_params) { {} }

        it "should return false" do
          parameters.match?(request).should be(false)
        end

      end

    end

    describe "when empty parameters are provided" do

      let(:params) { {} }

      describe "when the request contains no parameters" do

        let(:request_params) { {} }

        it "should return true" do
          parameters.match?(request).should be(true)
        end

      end

      describe "when the request contains parameters" do

        let(:request_params) { { "key" => "value" } }

        it "should return true" do
          parameters.match?(request).should be(true)
        end

      end

    end

    describe "when nil parameters are provided" do

      let(:params) { nil }

      describe "when the request contains no parameters" do

        let(:request_params) { {} }

        it "should return true" do
          parameters.match?(request).should be(true)
        end

      end

      describe "when the request contains parameters" do

        let(:request_params) { { "key" => "value" } }

        it "should return true" do
          parameters.match?(request).should be(true)
        end

      end

    end

  end

  describe "#to_s" do

    describe "when multiple parameters are provided" do

      let(:params) { { "key1" => "value1", "key2" => "value2", "key3" => "value3" } }

      it "should return a string containing each parameter formatted as a conventional request parameter" do
        result = parameters.to_s

        params.each { |key, value| result.should match(/#{key}=#{value}/) }
      end

      it "should separate each parameter with the conventional request parameter delimiter" do
        parameters.to_s.should match(/key\d=value\d\&key\d=value\d\&key\d=value\d/)
      end

    end

    describe "when empty parameters are provided" do

      let(:params) { {} }

      it "should return an empty string" do
        parameters.to_s.should eql("")
      end

    end

    describe "when nil parameters are provided" do

      let(:params) { nil }

      it "should return an empty string" do
        parameters.to_s.should eql("")
      end

    end

  end

end
