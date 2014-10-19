describe HttpStub::Configurer::Server::RememberedState do

  let(:remembered_state) { HttpStub::Configurer::Server::RememberedState.new }

  describe "#recall" do

    subject { remembered_state.recall }

    describe "when a number of commands have been added" do

      let(:commands) { (1..3).map { instance_double(HttpStub::Configurer::Server::Command) } }

      before(:example) { commands.each { |command| remembered_state << command } }

      it "executes each command added" do
        commands.each { |command| expect(command).to receive(:execute) }

        subject
      end

    end

    describe "when no commands have been added" do

      it "executes without error" do
        expect { subject }.not_to raise_error
      end

    end

  end

  describe "#filter" do

    describe "when a number of command have been added" do

      let(:commands) do
        (1..5).map do |i|
          double(HttpStub::Configurer::Server::Command, occasional_match_flag?: i % 2 == 0, no_match_flag?: false)
        end
      end

      before(:example) { commands.each { |command| remembered_state << command } }

      describe "when some commands match the filter provided" do

        it "returns a state containing the matching commands" do
          [ commands[1], commands[3] ].each { |command| expect(command).to receive(:execute) }

          filter_chain = remembered_state.filter(&:occasional_match_flag?)

          filter_chain.recall
        end

      end

      describe "when no commands match the filter provided" do

        it "returns an empty state" do
          filter_chain = remembered_state.filter(&:no_match_flag?)

          filter_chain.recall
        end

      end

    end

  end

end
