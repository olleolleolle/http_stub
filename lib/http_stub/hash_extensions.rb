module HttpStub

  module HashExtensions

    def downcase_keys
      self.reduce({}) do |result, element|
        result[element[0].is_a?(::String) ? element[0].downcase : element[0]] = element[1]
        result
      end
    end

    def has_hash?(other_hash)
      other_hash.nil? || other_hash.reduce(true) do |result, element|
        result && (self[element[0]] == element[1])
      end
    end

  end

end

::Hash.send(:include, HttpStub::HashExtensions)
