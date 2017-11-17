module HttpStub

  class HeadersFixture

    def self.many
      (1..3).each_with_object({}) { |i, hash| hash["header_name_#{i}"] = "value #{Random.string}" }
    end

  end

end
