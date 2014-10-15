describe HttpStub::Configurer::PatientCommandChain do

  let(:command_chain) { HttpStub::Configurer::PatientCommandChain.new }

  describe "#execute" do

    describe "when a number of commands have been added" do

      let(:commands) do
        (1..3).map { |i| double("Command#{i}") }
      end

      before(:example) do
        commands.each { |command| command_chain << command }
      end

      it "executes each command added" do
        commands.each { |command| expect(command).to receive(:execute) }

        command_chain.execute()
      end

    end

    describe "when no commands have been added" do

      it "executes without error" do
        expect { command_chain.execute() }.not_to raise_error
      end

    end

  end

  describe "#filter" do

    describe "when a number of command have been added" do

      let(:commands) do
        (1..5).map { |i| double("Command#{i}", occasional_match_flag?: i % 2 == 0, no_match_flag?: false) }
      end

      before(:example) do
        commands.each { |command| command_chain << command }
      end

      describe "when some commands match the filter provided" do

        it "returns a chain containing the matching commands" do
          [commands[1], commands[3]].each { |command| expect(command).to receive(:execute) }

          filter_chain = command_chain.filter(&:occasional_match_flag?)

          filter_chain.execute()
        end

      end

      describe "when no commands match the filter provided" do

        it "returns an empty chain" do
          filter_chain = command_chain.filter(&:no_match_flag?)

          filter_chain.execute()
        end

      end

    end

  end

end
