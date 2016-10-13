shared_context "surpressed output" do

  before(:example) do
    @original_stderr = $stderr
    $stderr = StringIO.new
  end

  after(:example) { $stderr = @original_stderr }

end
