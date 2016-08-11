describe "JSON configuration" do

  context "#to_json" do

    context "when a class has a custom implmentation" do

      module HttpStub
        module JSONConfiguration

          class HasCustomToJson

            attr_reader :data

            def initialize(name)
              @data = { "#{name}" => "#{name} value" }
            end

            def to_json(*args)
              @data.to_json(*args)
            end

            def method_missing(name, *args, &block)
              @data.send(name, *args, &block)
            end

          end
        end
      end

      context "and an instance is created" do

        let(:instance) { HttpStub::JSONConfiguration::HasCustomToJson.new(1) }

        subject { instance.to_json }

        it "returns the value produced by the custom implementation" do
          expect(subject).to eql(instance.data.to_json)
        end

      end

      context "and a list of instances is created" do

        let(:instances) { (1..3).map { |i| HttpStub::JSONConfiguration::HasCustomToJson.new(i) } }

        subject { instances.to_json }

        it "includes the JSON represenation of each instance" do
          instances.each { |instance| expect(subject).to include(instance.to_json) }
        end

        it "excludes any instance variables" do
          expect(subject).to_not include("data")
        end

      end

    end

  end

end
