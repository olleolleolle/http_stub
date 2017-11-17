shared_context "HTML view excluding a stub request" do

  it "returns a 200 response" do
    expect(response.code).to eql(200)
  end

  it "returns a response body that does not include the request" do
    expect(response.body).to_not include(escape_html(stub_request[:uri]))
  end

end
