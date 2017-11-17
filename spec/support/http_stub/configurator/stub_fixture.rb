module HttpStub
  module Configurator

    class StubFixture

      class << self

        def create_hash(args={})
          stub_id = args[:id] || next_id
          {
            id:          stub_id,
            match_rules: {
              uri:        "/uri/#{stub_id}",
              method:     :get,
              headers:    { "header_#{stub_id}"    => "header value #{stub_id}" },
              parameters: { "parameter_#{stub_id}" => "parameter value #{stub_id}" },
            },
            response:    {
              status: 200,
              body:   "body #{stub_id}"
            },
            triggers:    {
              scenario_names: [],
              stubs:          []
            }
          }
        end

        def create(args={})
          hash = self.create_hash(args)
          HttpStub::Configurator::Stub.create do |stub|
            stub.match_requests(hash[:match_rules])
            stub.respond_with(hash[:response])
            stub.trigger(hash[:triggers])
          end
        end

        def create_hashes
          (1..3).map { self.create_hash }
        end

        def many
          (1..3).map { self.create }
        end

        private

        def next_id
          @next_id ||= 0
          "#{@next_id += 1}"
        end

      end

    end

  end
end
