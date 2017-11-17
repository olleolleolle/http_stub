describe "Stub response block acceptance" do
  include_context "server integration"

  context "when a server configured with a stub containing a chain of response blocks is started" do

    let(:configurator) { HttpStub::Examples::ConfiguratorWithResponseBlocks }

    context "and a request is made matching the stub" do

      let(:header_value)    { "some header value" }
      let(:parameter_value) { "some parameter value" }

      let(:response) do
        HTTParty.get("#{server_uri}/some_path", headers: { "header_name"    => header_value },
                                                query:   { "parameter_name" => parameter_value })
      end

      describe "the response status" do

        it "is the value from the last declaring block" do
          expect(response.code).to eql(201)
        end

      end

      context "the response headers" do

        it "include headers from early in the chain that are not overridden" do
          expect(response.headers["header_defaulted"]).to eql("some default header value")
        end

        it "includes headers from the last declaring block" do
          expect(response.headers["header_overridden"]).to eql("some overridden header value")
        end

        it "includes interpolated values from the request headers" do
          expect(response.headers["header_referencing_header"]).to eql(header_value)
        end

        it "includes interpolated values from the request parameters" do
          expect(response.headers["header_referencing_parameter"]).to eql(parameter_value)
        end

      end

      context "the response body" do

        it "is the value from the last declaring block" do
          expect(response.body).to_not eql("some default body")
        end

        it "includes interpolated values from the request headers" do
          expect(response.body).to include(header_value)
        end

        it "includes interpolated values from the request headers" do
          expect(response.body).to include(parameter_value)
        end

      end

    end

  end

end
