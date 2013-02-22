require 'cover_me'
require 'rack/test'

require File.expand_path('../../lib/http_stub/start_server_rake_task', __FILE__)
require File.expand_path('../../lib/http_stub', __FILE__)
require File.expand_path('../../examples/configurer_with_alias', __FILE__)

Dir[File.expand_path('../support/**/*.rb', __FILE__)].each { |file| require file }
