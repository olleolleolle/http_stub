describe HttpStub::Extensions::Core::URI do

  it "patches ::URI" do
    expect(::URI.included_modules).to include(described_class)
  end

  describe "::add_parameters" do

    let(:original_parameters) { {} }
    let(:arg_parameters)      { {} }
    let(:uri)                 do
      uri = URI.parse("https://some-host:8888/some/path")
      uri.query = "#{URI.encode_www_form(original_parameters)}"
      uri.to_s
    end

    subject { ::URI.add_parameters(uri, arg_parameters) }

    it "preserves the uri's host, port and path" do
      expect(subject).to start_with("https://some-host:8888/some/path")
    end

    context "when the uri has parameters" do

      let(:original_parameters) { (1..3).each_with_object({}) { |i, hash| hash["parameter_#{i}"] = "value #{i}" } }

      context "and parameters are to be replaced" do

        let(:arg_parameters) { { "parameter_2" => "updated value 2", "parameter_3" => "updated value 3" } }

        it "replaces the parameters" do
          expect(effective_parameters).to include(arg_parameters)
        end

        it "retains other parameters" do
          expect(effective_parameters).to include("parameter_1" => "value 1")
        end

      end

      context "and other parameters are to be added" do

        let(:arg_parameters) do
           (1..3).each_with_object({}) { |i, hash| hash["another_parameter_#{i}"] = "another value #{i}" }
        end

        it "adds the parameter" do
          expect(effective_parameters).to include(arg_parameters)
        end

        it "retains other parameters" do
          expect(effective_parameters).to include(original_parameters)
        end

      end

    end

    context "when the uri does not have parameters" do

      let(:arg_parameters) { (1..3).each_with_object({}) { |i, hash| hash["parameter_#{i}"] = "value #{i}" } }

      it "adds the parameters" do
        expect(effective_parameters).to include(arg_parameters)
      end

    end

    def effective_parameters
      URI.decode_www_form(URI.parse(subject).query).to_h
    end

  end

end
