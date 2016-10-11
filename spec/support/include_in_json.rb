RSpec::Matchers.define :include_in_json do |expected_hash|

  match do |actual_json|
    actual_json.include?(expected_hash.to_json[1..-2])
  end

  description do
    "include JSON"
  end

  failure_message do |actual_json|
    "expected the JSON #{actual_json} to include #{expected_hash.to_json}"
  end

  failure_message_when_negated do |actual_json|
    "expected the JSON #{actual_json} to exclude #{expected_hash.to_json}"
  end

end
