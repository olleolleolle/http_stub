RSpec::Matchers.define :contain_file do |expected_path|

  match do |actual_response|
    actual_file = Tempfile.new(File.basename(expected_path)).tap do |file|
      file.write(actual_response.parsed_response)
      file.flush
    end
    FileUtils.compare_file(expected_path, actual_file.path)
  end

  description do
    "to contain contents of #{expected_path}"
  end

  failure_message do
    "expected the response to contain the contents of #{expected_path}"
  end

  failure_message_when_negated do
    "expected the response to not contain the contents of #{expected_path}"
  end

end
