module HttpStub
  module Extensions
    module Core

      module URI

        def self.included(mod)
          mod.extend(ClassMethods)
        end

        module ClassMethods

          def add_parameters(uri, parameters)
            parsed_uri = ::URI.parse(uri)
            existing_parameters = ::URI.decode_www_form(parsed_uri.query || "").to_h
            parsed_uri.query = ::URI.encode_www_form(existing_parameters.merge(parameters))
            parsed_uri.to_s
          end

        end

      end

    end
  end
end

::URI.send(:include, HttpStub::Extensions::Core::URI)
