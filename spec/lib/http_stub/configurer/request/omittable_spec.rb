describe HttpStub::Configurer::Request::Omittable do

  describe ".format" do

    context "when the value is a hash" do

      context "that contains entries with values that are :omitted" do

        let(:value) do
          (1..5).reduce({}) do |result, i|
            result["key#{i}"] = (i % 2 == 0) ? "value#{i}" : :omitted
            result
          end
        end

        it "returns a hash containing the omitted values converted to 'control:omitted'" do
          expected_hash = (1..5).reduce({}) do |result, i|
            result["key#{i}"] = (i % 2 == 0) ? "value#{i}" : "control:omitted"
            result
          end

          expect(perform_format).to eql(expected_hash)
        end

      end

      context "that contains no entries to be omitted" do

        let(:value) do
          (1..3).reduce({}) do |result, i|
            result["key#{i}"] = "value#{i}"
            result
          end
        end

        it "returns the hash unchanged" do
          expect(perform_format).to eql(value)
        end

      end

      context "that is empty" do

        let(:value) { {} }

        it "returns the hash unchanged" do
          expect(perform_format).to eql({})
        end

      end

    end

    context "when the value is not a hash" do

      let(:value) { "not a hash" }

      it "returns the value unchanged" do
        expect(perform_format).to eql(value)
      end

    end

    def perform_format
      HttpStub::Configurer::Request::Omittable.format(value)
    end

  end

end
