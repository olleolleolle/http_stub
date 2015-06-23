describe HttpStub::Configurer::Part do

  let(:configurer) do
    Class.new.tap { |configurer| configurer.send(:include, HttpStub::Configurer) }
  end

  let(:part_class) do
    Class.new.tap { |part_class| part_class.send(:include, HttpStub::Configurer::Part) }
  end

  let(:part)       { part_class.new }

  describe "#configure" do

    subject { part.configure(configurer) }

    shared_context "expect configure entity methods to be automatically invoke" do

      before(:example) do
        configure_method_names.each do |method_name|
          part_class.send(:define_method, method_name) do
            # Intentionally blank
          end
        end
      end

      it "invokes the configure methods" do
        configure_method_names.each { |method_name| expect(part).to receive(method_name) }

        subject
      end

    end

    context "when the part has configure stubs methods" do

      let(:configure_method_names) { (1..3).map { |i| "configure_resource_#{i}_stubs".to_sym } }

      include_context "expect configure entity methods to be automatically invoke"

    end

    context "when the part has configure stub methods" do

      let(:configure_method_names) { (1..3).map { |i| "configure_resource_#{i}_stub".to_sym } }

      include_context "expect configure entity methods to be automatically invoke"

    end

    context "when the part has configure scenarios methods" do

      let(:configure_method_names) { (1..3).map { |i| "configure_resource_#{i}_scenarios".to_sym } }

      include_context "expect configure entity methods to be automatically invoke"

    end

    context "when the part has configure scenario methods" do

      let(:configure_method_names) { (1..3).map { |i| "configure_resource_#{i}_scenario".to_sym } }

      include_context "expect configure entity methods to be automatically invoke"

    end

  end

end
