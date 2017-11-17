describe HttpStub::Configurator::Part do

  let(:configurator) do
    Class.new.tap { |configurator| configurator.send(:include, HttpStub::Configurator) }
  end

  let(:part_class) do
    Class.new.tap { |part_class| part_class.send(:include, HttpStub::Configurator::Part) }
  end

  let(:part) { part_class.new }

  describe "#apply_to" do

    subject { part.apply_to(configurator) }

    shared_context "expect configuration methods to be automatically invoked" do

      before(:example) do
        configuration_method_names.each do |method_name|
          part_class.send(:define_method, method_name) do
            # Intentionally blank
          end
        end
      end

      it "invokes the configuration methods" do
        configuration_method_names.each { |method_name| expect(part).to receive(method_name) }

        subject
      end

    end

    context "when the part has configured stubs methods" do

      let(:configuration_method_names) { (1..3).map { |i| "configure_resource_#{i}_stubs".to_sym } }

      include_context "expect configuration methods to be automatically invoked"

    end

    context "when the part has configured stub methods" do

      let(:configuration_method_names) { (1..3).map { |i| "configure_resource_#{i}_stub".to_sym } }

      include_context "expect configuration methods to be automatically invoked"

    end

    context "when the part has configured scenarios methods" do

      let(:configuration_method_names) { (1..3).map { |i| "configure_resource_#{i}_scenarios".to_sym } }

      include_context "expect configuration methods to be automatically invoked"

    end

    context "when the part has configured scenario methods" do

      let(:configuration_method_names) { (1..3).map { |i| "configure_resource_#{i}_scenario".to_sym } }

      include_context "expect configuration methods to be automatically invoked"

    end

  end

  context "when applied to a configurator" do

    before(:example) { part.apply_to(configurator) }

    describe "other methods on the part" do

      context "when available on the configurator" do

        it "are available on the part" do
          expect(part.respond_to?(:stub_server)).to be(true)
        end

        it "are delegated to the configurator" do
          expect(part.stub_server).to eql(configurator.stub_server)
        end

      end

      context "when not available on the configurator" do

        it "are not available on the part" do
          expect(part.respond_to?(:not_in_configurator)).to be(false)
        end

        it "raise an error on the part when invoked" do
          expect { part.not_in_configurator }.to raise_error(/#{part_class}/)
        end

      end

    end

  end

end
