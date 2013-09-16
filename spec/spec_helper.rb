require 'simplecov'
SimpleCov.start do
  add_filter "/spec/"
  add_filter "/vendor/"
  minimum_coverage 98.28
  refuse_coverage_drop
end if ENV["coverage"]

require 'httparty'
require 'nokogiri'
require 'rack/test'
require 'wait_until'

require File.expand_path('../../lib/http_stub/rake/task_generators', __FILE__)
require File.expand_path('../../lib/http_stub', __FILE__)
require File.expand_path('../../examples/configurer_with_class_activator', __FILE__)
require File.expand_path('../../examples/configurer_with_class_stub', __FILE__)
require File.expand_path('../../examples/configurer_with_complex_initializer', __FILE__)
require File.expand_path('../../examples/configurer_with_many_class_activators', __FILE__)

Dir[File.expand_path('../support/**/*.rb', __FILE__)].each { |file| require file }
