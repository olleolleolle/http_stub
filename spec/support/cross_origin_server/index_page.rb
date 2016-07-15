module CrossOriginServer

  class IndexPage

    def initialize(browser)
      @browser = browser
    end

    def load_and_wait_until_available
      @browser.navigate.to("http://localhost:8003/index.html")
      ::Wait.until!(description: "cross origin test page has loaded") { @browser.find_element(id: "scenario_name") }
    end

    def activate_scenario(name)
      @browser.find_element(id: "scenario_name").send_keys(name)
      @browser.find_element(id: "activate_scenario").click
    end

    def wait_for_response_indicator(indicator)
      ::Wait.until_true!(description: "cross origin request '#{indicator}'") do
        @browser.find_element(id: "response_indicator").text == indicator
      end
    end

  end
end
