module HttpStub
  module Server

    module Session

      MEMORY_SESSION_ID        = "http_stub_memory".freeze
      TRANSACTIONAL_SESSION_ID = "http_stub_transactional".freeze

      ID_ATTRIBUTE_NAME = :http_stub_session_id

    end

  end
end
