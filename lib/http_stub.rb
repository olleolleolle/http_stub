require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

require 'sinatra'
require 'immutable_struct'
require 'net/http'
require 'json'

require File.expand_path('../http_stub/response', __FILE__)
require File.expand_path('../http_stub/models/stub', __FILE__)
require File.expand_path('../http_stub/models/alias', __FILE__)
require File.expand_path('../http_stub/models/registry', __FILE__)
require File.expand_path('../http_stub/controllers/stub_controller', __FILE__)
require File.expand_path('../http_stub/controllers/alias_controller', __FILE__)
require File.expand_path('../http_stub/server', __FILE__)
require File.expand_path('../http_stub/configurer', __FILE__)
