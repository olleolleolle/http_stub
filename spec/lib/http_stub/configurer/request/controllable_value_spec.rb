describe HttpStub::Configurer::Request::ControllableValue do

  describe "::format" do

    let(:value) { "some value" }

    it "formats the potential control value via the Regexpable formatter" do
      expect(HttpStub::Configurer::Request::Regexpable).to receive(:format).with(value)

      perform_format
    end

    it "chains formatting by formatting the Regexpable formatter result via the Omittable formatter" do
      regexp_formatted_value = "some regexp formatted value"
      allow(HttpStub::Configurer::Request::Regexpable).to receive(:format).and_return(regexp_formatted_value)
      expect(HttpStub::Configurer::Request::Omittable).to receive(:format).with(regexp_formatted_value)

      perform_format
    end

    it "returns the Omittable formatter result" do
      omit_formatted_value = "some omit formatted value"
      allow(HttpStub::Configurer::Request::Omittable).to receive(:format).and_return(omit_formatted_value)

      expect(perform_format).to eql(omit_formatted_value)
    end

    def perform_format
      HttpStub::Configurer::Request::ControllableValue.format(value)
    end

  end

end
