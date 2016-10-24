describe HttpStub::Configurer::Server::SessionFacade do

  let(:session_id)        { "some session id" }
  let(:request_processor) { instance_double(HttpStub::Configurer::Server::RequestProcessor) }

  let(:session_facade) { described_class.new(session_id, request_processor) }

  describe "#stub_response" do

    let(:the_stub_description) { "some stub description" }
    let(:the_stub)             { instance_double(HttpStub::Configurer::Request::Stub, to_s: the_stub_description) }

    let(:request) { instance_double(HttpStub::Configurer::Request::Http::Multipart) }

    subject { session_facade.stub_response(the_stub) }

    before(:example) do
      allow(HttpStub::Configurer::Request::Http::Factory).to receive(:multipart).and_return(request)
      allow(request_processor).to receive(:submit)
    end

    it "creates a multipart request to add a stub" do
      expect(HttpStub::Configurer::Request::Http::Factory).to(
        receive(:multipart).with("stubs", anything, anything)
      )

      subject
    end

    it "creates a multipart request with the provided stub" do
      expect(HttpStub::Configurer::Request::Http::Factory).to receive(:multipart).with(anything, the_stub, anything)

      subject
    end

    it "creates a multipart request identifying the session" do
      expect(HttpStub::Configurer::Request::Http::Factory).to(
        receive(:multipart).with(anything, anything, http_stub_session_id: session_id)
      )

      subject
    end

    it "submits the request via the request processor" do
      expect(request_processor).to receive(:submit).with(hash_including(request: request))

      subject
    end

    it "describes the stub via its string representation" do
      expect(request_processor).to(
        receive(:submit).with(hash_including(description: a_string_including("stubbing '#{the_stub_description}'")))
      )

      subject
    end

    it "describes the request as scoped within the session" do
      expect(request_processor).to(
        receive(:submit).with(hash_including(description: a_string_including("session '#{session_id}'")))
      )

      subject
    end

  end

  describe "#activate" do

    let(:scenario_names) { (1..3).map { |i| "scenario name #{i}" } }
    let(:request)        { instance_double(HttpStub::Configurer::Request::Http::Basic) }

    subject { session_facade.activate(scenario_names) }

    before(:example) do
      allow(HttpStub::Configurer::Request::Http::Factory).to receive(:post).and_return(request)
      allow(request_processor).to receive(:submit)
    end

    it "creates an POST request to activate the scenarios" do
      expect(HttpStub::Configurer::Request::Http::Factory).to(
        receive(:post).with("scenarios/activate", anything).and_return(request)
      )

      subject
    end

    it "creates a POST request with the session id as a parameter" do
      expect(HttpStub::Configurer::Request::Http::Factory).to(
        receive(:post).with(anything, hash_including(http_stub_session_id: session_id)).and_return(request)
      )

      subject
    end

    it "creates a POST request with the scenario names as an array parameter" do
      expect(HttpStub::Configurer::Request::Http::Factory).to(
        receive(:post).with(anything, hash_including("names[]" => scenario_names)).and_return(request)
      )

      subject
    end

    it "submits the request via the request processor" do
      expect(request_processor).to receive(:submit).with(hash_including(request: request))

      subject
    end



    it "describes the activation request including the scenario names" do
      quoted_scenario_names = scenario_names.map { |name| "'#{name}'" }
      description_expectation = Regexp.new("activating #{quoted_scenario_names.join(", ")}")
      expect(request_processor).to(
        receive(:submit).with(hash_including(description: a_string_matching(description_expectation)))
      )

      subject
    end

    it "describes the request as scoped within the session" do
      expect(request_processor).to(
        receive(:submit).with(hash_including(description: a_string_including("session '#{session_id}'")))
      )

      subject
    end

  end

  describe "#reset_stubs" do

    let(:request) { instance_double(HttpStub::Configurer::Request::Http::Basic) }

    subject { session_facade.reset_stubs }

    before(:example) do
      allow(HttpStub::Configurer::Request::Http::Factory).to receive(:post).and_return(request)
      allow(request_processor).to receive(:submit)
    end

    it "creates a POST request to reset the stubs" do
      expect(HttpStub::Configurer::Request::Http::Factory).to(
        receive(:post).with("stubs/reset", anything).and_return(request)
      )

      subject
    end

    it "creates a POST request with the session id as a parameter" do
      expect(HttpStub::Configurer::Request::Http::Factory).to(
        receive(:post).with(anything, http_stub_session_id: session_id).and_return(request)
      )

      subject
    end

    it "submits the request via the request processor" do
      expect(request_processor).to receive(:submit).with(hash_including(request: request))

      subject
    end

    it "describes the request as resetting the stubs in memory" do
      expect(request_processor).to(
        receive(:submit).with(hash_including(description: a_string_including("resetting stubs")))
      )

      subject
    end

    it "describes the request as scoped within the session" do
      expect(request_processor).to(
        receive(:submit).with(hash_including(description: a_string_including("session '#{session_id}'")))
      )

      subject
    end

  end

  describe "#clear_stubs" do

    let(:request) { instance_double(HttpStub::Configurer::Request::Http::Basic) }

    subject { session_facade.clear_stubs }

    before(:example) do
      allow(HttpStub::Configurer::Request::Http::Factory).to receive(:delete).and_return(request)
      allow(request_processor).to receive(:submit)
    end

    it "creates a DELETE request that deletes a stub" do
      expect(HttpStub::Configurer::Request::Http::Factory).to(
        receive(:delete).with("stubs", anything).and_return(request)
      )

      subject
    end

    it "creates a DELETE request with the session id as a parameter" do
      expect(HttpStub::Configurer::Request::Http::Factory).to(
        receive(:delete).with(anything, http_stub_session_id: session_id).and_return(request)
      )

      subject
    end

    it "submits the request via the request processor" do
      expect(request_processor).to receive(:submit).with(hash_including(request: request))

      subject
    end

    it "describes the request as clearing the server stubs" do
      expect(request_processor).to(
        receive(:submit).with(hash_including(description: a_string_including("clearing stubs")))
      )

      subject
    end

    it "describes the request as scoped within the session" do
      expect(request_processor).to(
        receive(:submit).with(hash_including(description: a_string_including("session '#{session_id}'")))
      )

      subject
    end

  end

  describe "#delete" do

    let(:request) { instance_double(HttpStub::Configurer::Request::Http::Basic) }

    subject { session_facade.delete }

    before(:example) do
      allow(HttpStub::Configurer::Request::Http::Factory).to receive(:delete).and_return(request)
      allow(request_processor).to receive(:submit)
    end

    it "creates a DELETE request intended to delete a session" do
      expect(HttpStub::Configurer::Request::Http::Factory).to(
        receive(:delete).with("sessions", anything).and_return(request)
      )

      subject
    end

    it "creates a DELETE request with the session id as a parameter" do
      expect(HttpStub::Configurer::Request::Http::Factory).to(
        receive(:delete).with(anything, http_stub_session_id: session_id).and_return(request)
      )

      subject
    end

    it "submits the request via the request processor" do
      expect(request_processor).to receive(:submit).with(hash_including(request: request))

      subject
    end

    it "describes the request as clearing the server stubs" do
      expect(request_processor).to(
        receive(:submit).with(hash_including(description: a_string_including("deleting session '#{session_id}'")))
      )

      subject
    end

    it "describes the request as scoped within the session" do
      expect(request_processor).to(
        receive(:submit).with(hash_including(description: a_string_including("session '#{session_id}'")))
      )

      subject
    end

  end

end
