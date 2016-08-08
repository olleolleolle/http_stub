shared_context "HTML view excluding request details" do

  it "returns a 200 response" do
    expect(response.code).to eql(200)
  end

  it "returns a response body that does not include the request" do
    expect(response.body).to_not include(escape_html(stub_registrator.request_uri))
  end

end
