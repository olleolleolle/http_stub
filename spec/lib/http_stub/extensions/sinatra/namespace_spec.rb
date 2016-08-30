describe "Sinatra::Namespace loading customisations" do
  include Rake::DSL
  include_context "rack application test"

  class HttpStub::Extensions::SinatraNamespaceTestApplication < Sinatra::Base

    register Sinatra::Namespace

    namespace "/sinatra_namespace_extension" do

      get do
        halt 200
      end

    end

  end

  let(:app_class) { HttpStub::Extensions::SinatraNamespaceTestApplication }

  it "preserves Rake's namespace" do
    rake_namespace = namespace(:some_rake_namespace) {}
    expect(rake_namespace).to be_an_instance_of(Rake::NameSpace)
  end

  it "scopes Sinatra's namespace to be available to those extending Sinatra::Namespace" do
    issue_a_request

    expect(response.status).to eql(200)
  end

  def issue_a_request
    get "/sinatra_namespace_extension"
  end

end
