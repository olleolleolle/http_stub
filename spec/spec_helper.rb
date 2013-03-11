require 'simplecov'
SimpleCov.start do
  add_filter "/spec/"
  minimum_coverage 96.6
  refuse_coverage_drop
end if ENV["coverage"]

require 'rack/test'
require 'httparty'
require 'nokogiri'

require File.expand_path('../../lib/http_stub/start_server_rake_task', __FILE__)
require File.expand_path('../../lib/http_stub', __FILE__)
require File.expand_path('../../examples/configurer_with_activator', __FILE__)
require File.expand_path('../../examples/configurer_with_many_activators', __FILE__)

Dir[File.expand_path('../support/**/*.rb', __FILE__)].each { |file| require file }
