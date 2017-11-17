shared_context "HTML view including a stub request" do

  let(:ensure_stub_request_is_issued) { response }

  it "returns a 200 response" do
    expect(response.code).to eql(200)
  end

  it "returns a response body that contains the uri of the request" do
    ensure_stub_request_is_issued

    expect(response.body).to include(escape_html(stub_request[:uri]))
  end

  it "returns a response body that contains the method of the request" do
    ensure_stub_request_is_issued

    expect(response.body).to include(escape_html(stub_request[:method]))
  end

  it "returns a response body that contains the headers of the request whose names are in uppercase" do
    ensure_stub_request_is_issued

    stub_request[:headers].each do |expected_header_key, expected_header_value|
      expect(response.body).to include("#{expected_header_key.upcase}:#{expected_header_value}")
    end
  end

  context "when the request contains parameters" do

    before(:example) { stub_builder.with_request_parameters! }

    it "returns a response body that contains the parameters" do
      ensure_stub_request_is_issued

      stub_request[:parameters].each do |expected_parameter_key, expected_parameter_value|
        expect(response.body).to include("#{expected_parameter_key}=#{expected_parameter_value}")
      end
    end

  end

  context "when the request contains a body" do

    before(:example) { stub_builder.with_request_body! }

    it "returns a response body that contains the body" do
      ensure_stub_request_is_issued

      expect(response.body).to include("#{escape_html(stub_request[:body])}")
    end

  end

end
