require 'cover_me'
require 'rack/test'

require File.expand_path('../../lib/http/stub/rake_task', __FILE__)
require File.expand_path('../../lib/http_stub', __FILE__)

Dir[File.expand_path('../support/**/*.rb', __FILE__)].each { |file| require file }
