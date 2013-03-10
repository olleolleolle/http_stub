describe HttpStub::Models::StubHeaders do

  let(:request) { double("HttpRequest") }

  let(:stub_headers) { HttpStub::Models::StubHeaders.new(stubbed_headers) }

  describe "#match?" do

    before(:each) { HttpStub::Models::RequestHeaderParser.stub!(:parse).with(request).and_return(request_headers) }

    describe "when multiple headers are mandatory" do

      let(:stubbed_headers) { { "KEY1" => "value1", "KEY2" => "value2", "KEY3" => "value3" } }

      describe "and the mandatory headers are provided" do

        let(:request_headers) { stubbed_headers }

        describe "and the casing of the header names is identical" do

          it "should return true" do
            stub_headers.match?(request).should be_true
          end

        end

        describe "and the casing of the header names is different" do

          let(:stubbed_headers) { { "key1" => "value1", "KEY2" => "value2", "key3" => "value3" } }

          it "should return true" do
            stub_headers.match?(request).should be_true
          end

        end

        describe "and the mandatory request header names have hyphens in place of underscores" do

          let(:stubbed_headers) { { "KEY_1" => "value1", "KEY-2" => "value2", "KEY_3" => "value3" } }
          let(:request_headers) { { "KEY-1" => "value1", "KEY_2" => "value2", "KEY-3" => "value3" } }

          it "should return true" do
            stub_headers.match?(request).should be_true
          end

        end

      end

      describe "and the request headers have different values" do

        let(:request_headers) { { "KEY1" => "value1", "KEY2" => "doesNotMatch", "KEY3" => "value3" } }

        it "should return false" do
          stub_headers.match?(request).should be_false
        end

      end

      describe "and some mandatory headers are omitted" do

        let(:request_headers) { { "KEY1" => "value1", "KEY3" => "value3" } }

        it "should return false" do
          stub_headers.match?(request).should be_false
        end

      end

      describe "and all mandatory headers are omitted" do

        let(:request_headers) { {} }

        it "should return false" do
          stub_headers.match?(request).should be_false
        end

      end

    end

    describe "when no headers are mandatory" do

      let(:stubbed_headers) { {} }

      describe "and headers are provided" do

        let(:request_headers) { { "KEY" => "value" } }

        it "should return true" do
          stub_headers.match?(request).should be_true
        end

      end

    end

    describe "when the mandatory headers are nil" do

      let(:stubbed_headers) { nil }

      describe "and headers are provided" do

        let(:request_headers) { { "KEY" => "value" } }

        it "should return true" do
          stub_headers.match?(request).should be_true
        end

      end

    end

  end

  describe "#to_s" do

    describe "when multiple headers are provided" do

      let(:stubbed_headers) { { "key1" => "value1", "key2" => "value2", "key3" => "value3" } }

      it "should return a string containing each header formatted as a conventional request header" do
        result = stub_headers.to_s

        stubbed_headers.each { |key, value| result.should match(/#{key}:#{value}/) }
      end

      it "should comma delimit the headers" do
        stub_headers.to_s.should match(/key\d.value\d\, key\d.value\d\, key\d.value\d/)
      end

    end

    describe "when empty headers are provided" do

      let(:stubbed_headers) { {} }

      it "should return an empty string" do
        stub_headers.to_s.should eql("")
      end

    end

    describe "when nil headers are provided" do

      let(:stubbed_headers) { nil }

      it "should return an empty string" do
        stub_headers.to_s.should eql("")
      end

    end

  end

end
