describe HttpStub::Extensions::Rack::Handler do

  it "patches Rack::Handler" do
    expect(::Rack::Handler.included_modules).to include(HttpStub::Extensions::Rack::Handler)
  end

  context "when mixed in to a module" do

    module HttpStub::TestableRackHandler

      class << self

        attr_writer :handler

        def get(server)
          @handler
        end

      end

    end

    HttpStub::TestableRackHandler.send(:include, HttpStub::Extensions::Rack::Handler)

    describe "the modules ::get" do

      context "when the handler is runnable" do

        module HttpStub::SomeRunnableRackHandler

          def self.run
            # Intentionally blank
          end

        end

        before(:example) { HttpStub::TestableRackHandler.handler = HttpStub::SomeRunnableRackHandler }

        it "returns the handler" do
          expect(HttpStub::TestableRackHandler.get("SomeHandler")).to eql(HttpStub::SomeRunnableRackHandler)
        end

      end

      context "when the handler is not runnable" do

        module HttpStub::SomeUnRunnableRackHandler
        end

        before(:example) { HttpStub::TestableRackHandler.handler = HttpStub::SomeUnRunnableRackHandler }

        it "raises a NameError indicating the handler is invalid" do
          expect { HttpStub::TestableRackHandler.get("SomeHandler") }.to(
            raise_error(NameError, /SomeHandler Rack handler is invalid/)
          )
        end

      end

    end

  end

end
