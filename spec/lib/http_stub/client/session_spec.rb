describe HttpStub::Client::Session do

  let(:id)     { "some_session_id" }
  let(:server) { instance_double(HttpStub::Client::Server, submit!: nil) }

  let(:session) { described_class.new(id, server) }

  describe "#activate!" do

    let(:scenario_names) { (1..3).map { |i| "Scenario name #{i}" } }

    subject { session.activate!(*scenario_names) }

    it "submits a post request" do
      expect_request_submission_with(method: :post)

      subject
    end

    it "submits a request to the scenario activation endpoint" do
      expect_request_submission_with(path: "scenarios/activate")

      subject
    end

    it "creates a request identifying the session via a parameter" do
      expect_request_submission_with(parameters: hash_including(http_stub_session_id: id))

      subject
    end

    it "submits a request with the scenario names as a parameter" do
      expect_request_submission_with(parameters: hash_including("names[]" => scenario_names))

      subject
    end

    it "describes the intent of the request as to activate the provided scenarios" do
      scenario_names_description = scenario_names.map { |name| "'#{name}'" }.join(", ")
      expect_request_submission_with(intent: a_string_including("activate scenarios #{scenario_names_description}"))

      subject
    end

    it "the intent of the request includes the session affected" do
      expect_request_submission_with(intent: a_string_including("session '#{id}'"))

      subject
    end

  end

  describe "#reset!" do

    subject { session.reset! }

    it "submits a post request" do
      expect_request_submission_with(method: :post)

      subject
    end

    it "submits a request to the stubs reset endpoint" do
      expect_request_submission_with(path: "stubs/reset")

      subject
    end

    it "submits a request identifying the session via a parameter" do
      expect_request_submission_with(parameters: hash_including(http_stub_session_id: id))

      subject
    end

    it "describes the intent of the request as to reset stubs in the session" do
      expect_request_submission_with(intent: "reset stubs in session '#{id}'")

      subject
    end

  end

  describe "#delete!" do

    subject { session.delete! }

    it "submits a delete request" do
      expect_request_submission_with(method: :delete)

      subject
    end

    it "submits a request to the sessions endpoint" do
      expect_request_submission_with(path: "sessions")

      subject
    end

    it "submits a request identifying the session via a parameter" do
      expect_request_submission_with(parameters: hash_including(http_stub_session_id: id))

      subject
    end

    it "describes the intent of the request as to delete the session" do
      expect_request_submission_with(intent: "delete session '#{id}'")

      subject
    end

  end

  def expect_request_submission_with(element)
    expect(server).to receive(:submit!).with(hash_including(element))
  end

end
