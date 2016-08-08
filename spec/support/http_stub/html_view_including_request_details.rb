shared_context "HTML view including request details" do

  it "returns a 200 response" do
    expect(response.code).to eql(200)
  end

  it "returns a response body that contains the uri of the request" do
    expect(response.body).to include(escape_html(stub_registrator.request_body))
  end

  it "returns a response body that contains the method of the request" do
    expect(response.body).to include(escape_html(stub_registrator.request_method))
  end

  it "returns a response body that contains the headers of the request whose names are in uppercase" do
    stub_registrator.request_headers.each do |expected_header_key, expected_header_value|
      expect(response.body).to include("#{expected_header_key.upcase}:#{expected_header_value}")
    end
  end

  context "when the request contains parameters" do

    def configure_stub_registrator
      stub_registrator.with_request_parameters
    end

    it "returns a response body that contains the parameters" do
      stub_registrator.request_parameters.each do |expected_parameter_key, expected_parameter_value|
        expect(response.body).to include("#{expected_parameter_key}=#{expected_parameter_value}")
      end
    end

  end

  context "when the request contains a body" do

    def configure_stub_registrator
      stub_registrator.with_request_body
    end

    it "returns a response body that contains the body" do
      expect(response.body).to include("#{escape_html(stub_registrator.request_body)}")
    end

  end

end
