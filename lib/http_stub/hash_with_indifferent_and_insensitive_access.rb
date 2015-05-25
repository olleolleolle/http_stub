module HttpStub

  class HashWithIndifferentAndInsensitiveAccess < HashWithIndifferentAccess

    def [](key)
      self.key?(key) ? super : insensitive_find(key)
    end

    private

    def insensitive_find(key)
      entry = self.find { |entry_key, _entry_value| entry_key.to_s.downcase == key.to_s.downcase }
      entry ? entry[1] : nil
    end

  end

end
