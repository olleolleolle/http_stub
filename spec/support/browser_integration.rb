shared_context "browser integration" do

  let(:browser) do
    Selenium::WebDriver.for(:firefox).tap { @browser_launched = true }
  end

  after(:example) { browser.quit if @browser_launched }

end
