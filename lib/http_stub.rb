require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

require 'sinatra'
require 'immutable_struct'
require 'net/http'
require 'json'

require File.expand_path('../http_stub/stub', __FILE__)
require File.expand_path('../http_stub/registry', __FILE__)
require File.expand_path('../http_stub/server', __FILE__)
require File.expand_path('../http_stub/client', __FILE__)
