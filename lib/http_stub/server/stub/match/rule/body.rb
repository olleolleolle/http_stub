module HttpStub
  module Server
    module Stub
      module Match
        module Rule

          class Body

            def self.create(body)
              if body.is_a?(Hash)
                HttpStub::Server::Stub::Match::Rule::SchemaBody.create(body.with_indifferent_access[:schema])
              elsif body.present?
                HttpStub::Server::Stub::Match::Rule::SimpleBody.new(body)
              else
                HttpStub::Server::Stub::Match::Rule::Truthy
              end
            end

          end

        end
      end
    end
  end
end
