describe "Request references in response acceptance" do
  include_context "configurer integration with stubs recalled"

  def configurer
    HttpStub::Examples::ConfigurerWithRequestReferences
  end

  context "when a request is made matching a stub that references request attributes" do

    let(:header_value)    { "some header value" }
    let(:parameter_value) { "some parameter value" }

    let(:response) do
      HTTParty.get("#{server_uri}/some_path", headers: { "header_name"    => header_value },
                                              query:   { "parameter_name" => parameter_value })
    end

    context "the response headers" do

      it "include request headers" do
        expect(response.headers["header_referencing_header"]).to eql(header_value)
      end

      it "include request parameters" do
        expect(response.headers["header_referencing_parameter"]).to eql(parameter_value)
      end

    end

    context "the response body" do

      it "include request headers" do
        expect(response.body).to include(header_value)
      end

      it "include request parameters" do
        expect(response.body).to include(parameter_value)
      end

    end

  end

end
