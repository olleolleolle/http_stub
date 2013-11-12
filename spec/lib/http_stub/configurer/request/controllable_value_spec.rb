describe HttpStub::Configurer::Request::ControllableValue do

  describe ".format" do

    let(:value) { "some value" }

    it "should format the potential control value via the Regexpable formatter" do
      HttpStub::Configurer::Request::Regexpable.should_receive(:format).with(value)

      perform_format
    end

    it "should chain formatting by formatting the Regexpable formatter result via the Omittable formatter" do
      regexp_formatted_value = "some regexp formatted value"
      HttpStub::Configurer::Request::Regexpable.stub(:format).and_return(regexp_formatted_value)
      HttpStub::Configurer::Request::Omittable.should_receive(:format).with(regexp_formatted_value)

      perform_format
    end

    it "should return the Omittable formatter result" do
      omit_formatted_value = "some omit formatted value"
      HttpStub::Configurer::Request::Omittable.stub(:format).and_return(omit_formatted_value)

      perform_format.should eql(omit_formatted_value)
    end

    def perform_format
      HttpStub::Configurer::Request::ControllableValue.format(value)
    end

  end

end
