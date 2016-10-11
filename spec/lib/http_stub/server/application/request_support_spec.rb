describe HttpStub::Server::Application::RequestSupport do

  context "when included in an application" do
    include_context "rack application test"

    class HttpStub::Server::Application::RequestSupport::TestApplication < Sinatra::Base
      include HttpStub::Server::Application::RequestSupport

      def initialize(session_configuration, server_memory)
        @session_configuration = session_configuration
        @server_memory         = server_memory
        super()
      end

      get "/request_support_test" do
        halt 200
      end

    end

    let(:session_configuration) { instance_double(HttpStub::Server::Session::Configuration) }
    let(:server_memory)         { instance_double(HttpStub::Server::Memory::Memory) }
    let(:request_factory)       { instance_double(HttpStub::Server::Request::Factory) }

    let(:app_class) { HttpStub::Server::Application::RequestSupport::TestApplication }
    let(:app)       { app_class.new!(session_configuration, server_memory) }

    describe "constructor" do

      subject { app }

      it "creates a factory for creating http_stub using the servers session configuration" do
        expect(HttpStub::Server::Request::Factory).to receive(:new).with(session_configuration, anything)

        subject
      end

      it "creates a factory for creating http_stub requests based on the servers memory" do
        expect(HttpStub::Server::Request::Factory).to receive(:new).with(anything, server_memory)

        subject
      end

    end

    describe "when servicing a request" do

      subject { get "/request_support_test" }

      it "creates a http_stub request for rack requests issued" do
        allow(HttpStub::Server::Request::Factory).to receive(:new).and_return(request_factory)
        expect(request_factory).to receive(:create).with(a_kind_of(Rack::Request), anything, anything)

        subject
      end

    end

  end

end
