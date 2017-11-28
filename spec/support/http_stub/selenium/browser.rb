module HttpStub
  module Selenium

    class Browser

      class << self

        def instance
          @instance ||= ::Selenium::WebDriver.for(:firefox)
        end

        def stop!
          @instance.try(:quit)
        end

      end

    end

  end
end